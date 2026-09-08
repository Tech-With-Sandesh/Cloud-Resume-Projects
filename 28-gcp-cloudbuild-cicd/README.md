# Project 28 - GCP Cloud Build CI/CD: GitHub → Cloud Build → Artifact Registry → Cloud Run

## Problem Statement

Your team needs a fully managed CI/CD pipeline on GCP with:
- Trigger on every push to `main` branch
- Run tests before building
- Build and push Docker image to Artifact Registry with commit SHA tag
- Deploy to Cloud Run automatically
- All build logs in Cloud Logging (no self-managed build servers)

---

## Architecture

```
Developer → git push → GitHub (main branch)
                │
                ▼ (Cloud Build GitHub trigger)
          Cloud Build (E2_HIGHCPU_8)
                │
    ┌───────────┼──────────────┐
    ▼           ▼              ▼
  pytest      docker build   gcloud run deploy
  (tests)   + push to AR     (Cloud Run)
              ($SHORT_SHA)
```

---

## Project Structure

```
28-gcp-cloudbuild-cicd/
├── cloudbuild/
│   └── cloudbuild.yaml    ← 4-step pipeline: test → build → push → deploy
└── app/
    ├── main.py
    ├── Dockerfile
    └── requirements.txt
```

---

## Step 1 — Enable APIs

```bash
gcloud services enable \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  --project YOUR_PROJECT_ID
```

---

## Step 2 — Grant Cloud Build Permissions

```bash
PROJECT_ID="YOUR_PROJECT_ID"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CB_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$CB_SA" --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$CB_SA" --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$CB_SA" --role="roles/artifactregistry.writer"
```

---

## Step 3 — Create Cloud Build GitHub Trigger

1. Cloud Console → **Cloud Build** → **Triggers** → **Create Trigger**
2. Configure:
   - Name: `github-main-trigger`
   - Event: `Push to a branch`
   - Source: Connect GitHub repository
   - Branch: `^main$`
   - Cloud Build configuration file: `cloudbuild/cloudbuild.yaml`
3. Substitution variables:
   - `_REGION` = `us-central1`
   - `_REPO_NAME` = `cloud-run-app`
   - `_SERVICE_NAME` = `cloud-run-app`
4. Click **Create**

---

## Step 4 — Trigger the Pipeline

```bash
git add .
git commit -m "feat: add Cloud Build CI/CD"
git push origin main
```

Watch the build:

```bash
gcloud builds list --project YOUR_PROJECT_ID --limit 5
```

---

## Step 5 — Monitor Build Stages

Cloud Console → **Cloud Build** → **History** → Click build:

```
✅ run-tests     — pytest passes
✅ build-image   — Docker image built with $SHORT_SHA tag
✅ push-image    — Pushed to Artifact Registry
✅ deploy-cloud-run — Cloud Run service updated
```

---

## Step 6 — Verify Cloud Run Deployment

```bash
gcloud run services describe cloud-run-app \
  --region us-central1 \
  --format="value(status.url)"
```

```bash
SERVICE_URL=$(gcloud run services describe cloud-run-app --region us-central1 --format="value(status.url)")
curl "$SERVICE_URL/health"
```

---

## Verification Checklist

✅ Cloud Build trigger connected to GitHub

✅ Push to `main` triggers pipeline automatically

✅ `run-tests` step: pytest passes (or pipeline fails)

✅ Docker image in Artifact Registry tagged with `$SHORT_SHA`

✅ Cloud Run service updated with new image SHA

✅ `/health` returns 200 on new Cloud Run revision

---

## Troubleshooting

**Build fails with `PERMISSION_DENIED` on Cloud Run deploy:**
- Ensure Cloud Build SA has `roles/run.admin` and `roles/iam.serviceAccountUser`

**Tests fail — `ModuleNotFoundError`:**
- Check `requirements.txt` includes all dependencies (including pytest)
- Verify `pip install -r requirements.txt` runs before pytest

**Push to Artifact Registry fails:**
- Grant `roles/artifactregistry.writer` to Cloud Build SA

---

## Cleanup

```bash
gcloud run services delete cloud-run-app --region us-central1
gcloud builds triggers delete github-main-trigger
```

---

## Key Learnings

- Cloud Build YAML (steps, waitFor, substitutions, options, timeout)
- `$SHORT_SHA` built-in substitution (git commit SHA short form — immutable image tag)
- `waitFor` (explicit step dependency DAG — parallel vs sequential steps)
- Cloud Build substitutions (overrideable defaults per trigger)
- Cloud Build machine type (`E2_HIGHCPU_8` — faster build for CPU-intensive steps)
- Cloud Build SA permissions (least-privilege for deploy + registry)
- `logging: CLOUD_LOGGING_ONLY` (all logs in Cloud Logging, no GCS bucket needed)
- Artifact Registry `--all-tags` push (push both SHA and latest in one command)
- GitHub integration (Cloud Build GitHub App — webhook trigger)
- `gcloud run deploy` from Cloud Build (fully managed zero-downtime update)
