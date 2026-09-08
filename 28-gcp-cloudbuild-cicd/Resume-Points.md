# Resume Points — Project 28: GCP Cloud Build CI/CD

---

## Fresher

- Built a 4-step GCP Cloud Build CI/CD pipeline triggered on GitHub push to `main`: pytest → Docker build (tagged with $SHORT_SHA) → Artifact Registry push → Cloud Run deploy — fully managed, zero Jenkins servers.
- Used `$SHORT_SHA` built-in Cloud Build substitution for Docker image tagging — each build produces an immutable, git-traceable image tag linking deployments to exact source commits.
- Configured `waitFor` in cloudbuild.yaml to define step dependency order — `build-image` waits for `run-tests`, `push-image` waits for `build-image`, `deploy-cloud-run` waits for `push-image`.
- Granted least-privilege IAM to Cloud Build service account: `roles/run.admin`, `roles/iam.serviceAccountUser`, and `roles/artifactregistry.writer` — only the permissions required for deployment.

---

## Experienced Cloud Engineer

- Designed a GCP-native CI/CD pipeline using Cloud Build YAML: 4 steps with explicit `waitFor` DAG dependencies, substitution variables for environment-specific overrides per trigger, `E2_HIGHCPU_8` machine type for faster Docker build, `logging: CLOUD_LOGGING_ONLY` (no GCS bucket for logs), 1200s timeout.
- Implemented commit SHA image tagging with `$SHORT_SHA`: every Cloud Run revision is linked to an exact git commit, enabling audit trail (`gcloud run revisions list` shows image digest → tag → commit SHA chain) and trivial rollback.
- Applied `--all-tags` Docker push to push both `$SHORT_SHA` and `latest` tags in a single command, and `gcloud run deploy` with `--image=$SHORT_SHA` tag ensuring Cloud Run always runs the exact build artifact, not an unversioned `latest`.
- Documented Cloud Build private pool (VPC-connected build environments), approval gates for production (Cloud Build manual approval step), and supply chain security (Binary Authorization — only signed images can be deployed to Cloud Run).

---

## LinkedIn Project Description

Built a GCP Cloud Build CI/CD pipeline (4 steps, waitFor DAG: pytest → Docker build + push to Artifact Registry → gcloud run deploy). $SHORT_SHA immutable image tagging, substitution variables, E2_HIGHCPU_8 machine, CLOUD_LOGGING_ONLY, 1200s timeout. Least-privilege Cloud Build SA (run.admin + artifactregistry.writer). GitHub trigger on main branch push. Production: Binary Authorization, approval gates, private pools.

---

## How to Explain in an Interview (30 Seconds)

"I built a Cloud Build pipeline with four steps: tests, Docker build, Artifact Registry push, and Cloud Run deploy. The key design pattern is using $SHORT_SHA for image tagging — every Docker image gets tagged with the 7-character git commit hash, so when I look at Cloud Run revisions, I can trace exactly which git commit is running in production. I defined waitFor dependencies explicitly between steps so they run sequentially in the right order. Cloud Build handles everything — no Jenkins, no self-hosted runners, no infrastructure to manage."

---

## Skills Demonstrated

- GCP Cloud Build YAML (steps, waitFor, substitutions, options, timeout)
- $SHORT_SHA (immutable git commit-based image tagging)
- waitFor (explicit DAG step dependencies)
- Cloud Build substitutions (_REGION, _REPO_NAME overrideable per trigger)
- Cloud Build machine type (E2_HIGHCPU_8 for faster builds)
- CLOUD_LOGGING_ONLY (streamlined log configuration)
- GitHub Cloud Build trigger (push event, branch filter)
- Artifact Registry --all-tags (SHA + latest in one push)
- gcloud run deploy from Cloud Build (managed zero-downtime update)
- Cloud Build SA least-privilege (run.admin, serviceAccountUser, AR writer)
- Binary Authorization (supply chain security — production path)
