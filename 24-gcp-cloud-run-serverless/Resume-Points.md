# Resume Points — Project 24: GCP Cloud Run Serverless

---

## Fresher

- Deployed a containerised Flask application on GCP Cloud Run (v2) with scale-to-zero (`min_instance_count=0`), automatic HTTPS, and startup/liveness probes.
- Built and pushed Docker image to GCP Artifact Registry using `gcloud auth configure-docker` and standard `docker push` commands.
- Configured `cpu_idle = true` on Cloud Run container — CPU is only allocated during active request handling, reducing costs when idle.
- Set `max_instance_count = 10` for automatic scaling under load and dedicated Service Account for least-privilege GCP API access.

---

## Experienced Cloud Engineer

- Architected a fully serverless container deployment: Artifact Registry (DOCKER format, regional) → Cloud Run v2 (min=0 scale-to-zero, max=10, cpu_idle, gunicorn threads=8 for concurrency, startup+liveness probes) → automatic HTTPS on `*.run.app` domain — zero Kubernetes management, zero idle cost.
- Configured Cloud Run's concurrent request model: gunicorn with `--threads 8` allows each container instance to handle 8 concurrent requests — enabling Cloud Run's per-instance concurrency (default 80), minimising cold starts at low traffic.
- Implemented startup probe (longer tolerance for first container start) separate from liveness probe (continuous health monitoring) — startup probe allows 30s initialisation without triggering container restarts.
- Documented Cloud Run traffic splitting (canary/blue-green via `--traffic LATEST=10,STABLE=90`), Cloud Run Jobs for batch workloads, and minimum instances for latency-sensitive APIs.

---

## LinkedIn Project Description

Deployed a serverless Flask container on GCP Cloud Run v2 — scale-to-zero (min=0), auto-scale (max=10), cpu_idle (cost optimised), startup probe + liveness probe, gunicorn (8 threads for Cloud Run concurrency), HTTPS auto-provisioned. Artifact Registry (DOCKER format). Service Account (least-privilege). IAM: allUsers roles/run.invoker (public API). Terraform deployment.

---

## How to Explain in an Interview (30 Seconds)

"I deployed a containerised API on GCP Cloud Run. The key design choice was scale-to-zero — when there's no traffic, Cloud Run shuts down all instances and you pay nothing. When traffic comes in, it spins up new instances in milliseconds. I set cpu_idle to true so the CPU is only allocated during actual request processing, not while the container is waiting. For the Docker image, I used GCP Artifact Registry instead of Docker Hub — it's in the same VPC network, so image pulls are faster and more secure. Cloud Run handles HTTPS automatically on the run.app domain."

---

## Skills Demonstrated

- GCP Cloud Run v2 (serverless containers, managed scaling)
- Scale-to-zero (min_instance_count=0, cpu_idle)
- Artifact Registry (DOCKER format, gcloud auth configure-docker)
- Cloud Run PORT convention (container must listen on $PORT=8080)
- Startup probe vs liveness probe (separate concerns)
- Gunicorn threads (Cloud Run concurrency model)
- Service Account (least-privilege container identity)
- roles/run.invoker (IAM for public API access)
- Automatic HTTPS (GCP-managed TLS on *.run.app)
- Cloud Run traffic splitting (canary/blue-green deployments)
- Cloud Run Jobs (batch workloads variant)
