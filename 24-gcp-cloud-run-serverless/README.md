# Project 24 - GCP Cloud Run Serverless Container with Artifact Registry

## Problem Statement

Your team needs to deploy containers without managing Kubernetes or VMs:
- Scale to zero (pay nothing when idle)
- Scale from zero to 10 instances in seconds under load
- Private container registry (Artifact Registry)
- Startup and liveness probes for health monitoring
- HTTPS automatically provided by GCP

Deploy a serverless container using GCP Cloud Run + Artifact Registry.

---

## Architecture

```
Developer → docker push → Artifact Registry (us-central1-docker.pkg.dev)
                │
                ▼ (Terraform deploy)
         Cloud Run Service (us-central1)
                │
                ├── min_instances: 0 (scale to zero)
                ├── max_instances: 10 (auto-scale up)
                ├── cpu_idle: true (CPU allocated only on requests)
                ├── Startup probe: /health (port 8080)
                └── Liveness probe: /health (30s interval)
                │
                ▼ HTTPS (auto-provisioned by GCP)
         https://cloud-run-app-xxx.run.app
```

---

## Project Structure

```
24-gcp-cloud-run-serverless/
├── app/
│   ├── main.py          ← Flask app (/health, /, /echo)
│   ├── Dockerfile       ← Non-root, PORT env var, gunicorn threads
│   └── requirements.txt
└── terraform/
    ├── main.tf   ← Artifact Registry, Service Account, Cloud Run, IAM
    ├── variables.tf
    └── outputs.tf
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| Terraform | ≥ 1.3.0 |
| gcloud CLI | [cloud.google.com/sdk](https://cloud.google.com/sdk/docs/install) |
| Docker | ≥ 24.0 |

---

## Step 1 — Enable APIs and Authenticate

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com
```

---

## Step 2 — Deploy Infrastructure

```bash
cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

---

## Step 3 — Build and Push Image

```bash
PROJECT_ID="YOUR_PROJECT_ID"
REGION="us-central1"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/cloud-run-app/webapp:latest"

# Authenticate Docker to Artifact Registry
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Build and push
cd ../app/
docker build -t "$IMAGE" .
docker push "$IMAGE"
```

---

## Step 4 — Update Cloud Run with New Image

```bash
cd ../terraform/
terraform apply -var="project_id=$PROJECT_ID" -var="image_tag=latest"
```

Or deploy directly:

```bash
gcloud run deploy cloud-run-app \
  --image "$IMAGE" \
  --region us-central1 \
  --platform managed
```

---

## Step 5 — Test the Service

```bash
SERVICE_URL=$(terraform output -raw service_url)

curl "$SERVICE_URL/health"
# {"status": "healthy", "service": "cloud-run-app"}

curl "$SERVICE_URL/"
# {"message": "Hello from GCP Cloud Run!", "project": "...", "region": "us-central1"}

curl -X POST "$SERVICE_URL/echo" \
  -H "Content-Type: application/json" \
  -d '{"test": "hello"}'
# {"echo": {"test": "hello"}}
```

---

## Step 6 — View Logs

```bash
gcloud run services logs read cloud-run-app --region us-central1 --limit 50
```

---

## Step 7 — Monitor in Cloud Console

Go to **Cloud Run** → `cloud-run-app` → **Metrics** tab to see:
- Request count
- Request latency (p50/p95/p99)
- Container instance count (scale-to-zero in action)
- Memory utilisation

---

## Verification Checklist

✅ Artifact Registry repository created

✅ Docker image pushed to Artifact Registry

✅ Cloud Run service deployed with HTTPS URL

✅ `min_instance_count = 0` (scale to zero)

✅ `max_instance_count = 10` (auto-scale)

✅ `/health` returns 200

✅ `allUsers` IAM binding (public access)

✅ Automatic HTTPS on `*.run.app` domain

---

## Troubleshooting

**`Error: PERMISSION_DENIED` deploying Cloud Run:**
- Ensure `roles/run.admin` and `roles/iam.serviceAccountUser` are on your account
- Enable API: `gcloud services enable run.googleapis.com`

**Container fails to start:**
- Cloud Run requires container to listen on `$PORT` (default 8080)
- Check logs: `gcloud run services logs read cloud-run-app --region us-central1`

**Image pull error:**
- Verify Artifact Registry region matches Cloud Run region
- Authenticate Docker: `gcloud auth configure-docker us-central1-docker.pkg.dev`

---

## Cleanup

```bash
gcloud run services delete cloud-run-app --region us-central1
cd terraform/ && terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

---

## Key Learnings

- GCP Cloud Run v2 (serverless containers, managed HTTPS, auto-scaling)
- Scale-to-zero (`min_instance_count=0`) vs always-on (`min_instance_count=1`)
- `cpu_idle = true` (CPU only allocated during request handling — cost optimisation)
- Artifact Registry (DOCKER format, replaces Container Registry)
- Cloud Run `PORT` environment variable (container must listen on this port)
- Startup probe vs liveness probe (startup allows longer init time)
- `roles/run.invoker` for `allUsers` (public API access)
- Service Account for Cloud Run (least-privilege GCP API access from container)
- Gunicorn `--threads 8` (concurrency for Cloud Run's concurrent request model)
- Cloud Run traffic splitting (blue/green deployments via traffic percent)
