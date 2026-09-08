# Project 21 - Azure Container Registry with ACR Tasks and Azure Container Instances

## Problem Statement

Your team needs a private container registry on Azure with:
- Private registry (no Docker Hub dependency)
- Cloud-native Docker builds (no local Docker daemon required)
- Automatic image vulnerability scanning
- Run containers without Kubernetes overhead (Azure Container Instances)
- Credential-free ACI → ACR authentication via Managed Identity

---

## Architecture

```
Source Code
  │
  ▼ az acr build (cloud build — no local Docker)
Azure Container Registry (Standard SKU)
  ├── Image scanning on push
  ├── Retention policy (30 days)
  └── AcrPull → User-Assigned Managed Identity
                │
                ▼
    Azure Container Instances
    (0.5 vCPU, 0.5GB — public IP, liveness probe)
    Access: http://FQDN:5000
```

---

## Project Structure

```
21-azure-container-registry/
├── app/
│   ├── app.py           ← Flask app
│   ├── Dockerfile
│   └── requirements.txt
└── terraform/
    ├── main.tf   ← ACR, User-Assigned Identity, AcrPull role, ACI
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy Infrastructure

```bash
az group create --name acr-rg --location eastus
cd terraform/
terraform init && terraform apply
```

---

## Step 2 — Build and Push Image (Cloud Build)

```bash
ACR_NAME=$(terraform output -raw acr_login_server | cut -d. -f1)

# Build in ACR (no local Docker needed!)
az acr build \
  --registry "$ACR_NAME" \
  --image webapp:1.0.0 \
  ../app/

# List images
az acr repository list --name "$ACR_NAME" --output table
```

---

## Step 3 — Deploy ACI with New Image

```bash
# After pushing image, update the ACI
terraform apply -var="image_tag=1.0.0"
```

---

## Step 4 — Test the Application

```bash
FQDN=$(terraform output -raw aci_fqdn)

curl "http://$FQDN:5000/health"
# Expected: {"status": "healthy", "service": "acr-demo", "hostname": "..."}

curl "http://$FQDN:5000/"
# Expected: {"message": "Hello from Azure Container Registry!", "version": "1.0.0"}
```

---

## Step 5 — View Image Vulnerabilities

```bash
ACR_NAME=$(terraform output -raw acr_login_server | cut -d. -f1)

az acr manifest list-metadata \
  --registry "$ACR_NAME" \
  --name webapp \
  --query "[].{Tag:tags[0], Digest:digest}"
```

---

## Verification Checklist

✅ ACR created (Standard SKU, admin disabled)

✅ `az acr build` succeeds — image in ACR

✅ User-Assigned Managed Identity with AcrPull role

✅ ACI pulls image using Managed Identity (no credentials)

✅ ACI container `Running` state

✅ `/health` returns 200

✅ Image scan completed in ACR (check ACR → Repositories → image → Vulnerabilities)

---

## Troubleshooting

**ACI fails to pull image:**
- Verify role assignment propagation: wait 2 minutes after `terraform apply`
- Check identity is attached: `az container show --name cloud-acr-aci --resource-group acr-rg --query identity`

**`az acr build` fails:**
- Ensure Azure CLI is logged in: `az login`
- Check ACR name is correct (lowercase, alphanumeric only)

---

## Cleanup

```bash
terraform destroy
az group delete --name acr-rg --yes
```

---

## Key Learnings

- Azure Container Registry (Standard SKU, admin disabled, retention policy)
- `az acr build` (cloud-native Docker builds — Dockerfile sent to ACR, no local Docker)
- User-Assigned Managed Identity for ACI (credential-free ACR pull)
- AcrPull role assignment (least-privilege image pull)
- Azure Container Instances (serverless containers — no K8s overhead)
- ACI liveness probe (HTTP health check)
- image_registry_credential with managed identity (not username/password)
- Retention policy (auto-delete untagged images after 30 days)
- ACR vulnerability scanning on push (Defender for Containers)
- ACI DNS label (FQDN for container access)
