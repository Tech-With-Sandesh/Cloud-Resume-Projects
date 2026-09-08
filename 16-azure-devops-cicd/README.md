# Project 16 - Azure DevOps CI/CD Pipeline: GitHub → Azure Pipelines → ACR → AKS

## Problem Statement

Your team needs a managed CI/CD pipeline on Azure with:
- Automatic trigger on push to `main` branch
- Unit tests must pass before build
- Docker image built and pushed to Azure Container Registry
- Automatic deployment to Azure Kubernetes Service
- Environment approvals for production gate

Build a 3-stage Azure Pipeline: Build → Push → Deploy.

---

## Architecture

```
Developer → git push → Azure Repos / GitHub
                │
                ▼ (trigger: main branch)
         Azure Pipelines
                │
    ┌───────────┼───────────────┐
    ▼           ▼               ▼
  Build        Push           Deploy
  (pytest)   (Docker→ACR)   (KubernetesManifest→AKS)
                               │
                    Environment: production
                    (manual approval gate optional)
```

---

## Project Structure

```
16-azure-devops-cicd/
├── pipelines/
│   └── azure-pipelines.yml   ← 3-stage pipeline: Build+Test → Push ACR → Deploy AKS
└── app/
    ├── Dockerfile
    ├── requirements.txt
    └── tests/
```

---

## Prerequisites

| Tool | Notes |
|------|-------|
| Azure DevOps organisation | [dev.azure.com](https://dev.azure.com) |
| Azure subscription | Linked to Azure DevOps |
| AKS cluster | From Project 15 |
| ACR | From Project 15 |

---

## Step 1 — Create Azure DevOps Project

1. Go to [dev.azure.com](https://dev.azure.com) → **New project**
2. Name: `cloud-cicd-project`, Visibility: Private

---

## Step 2 — Create Service Connections

### ACR Service Connection

1. **Project Settings** → **Service connections** → **New**
2. Type: **Docker Registry** → Azure Container Registry
3. Select your subscription and ACR → Name: `acr-service-connection`

### Azure Resource Manager Connection

1. **New service connection** → **Azure Resource Manager**
2. Scope: **Subscription** → Name: `azure-service-connection`

---

## Step 3 — Update Pipeline Variables

Edit `pipelines/azure-pipelines.yml`:

```yaml
containerRegistry: 'YOURACR.azurecr.io'
aksClusterName:    'cloud-aks-aks'
aksResourceGroup:  'aks-rg'
```

---

## Step 4 — Create Pipeline

1. Azure DevOps → **Pipelines** → **New Pipeline**
2. **Where is your code?** → GitHub (or Azure Repos)
3. Select your repository
4. **Existing Azure Pipelines YAML file** → `/pipelines/azure-pipelines.yml`
5. Click **Run**

---

## Step 5 — Monitor Pipeline Stages

Azure Pipelines → your pipeline → view stages:

```
✅ Build and Test    — pytest passes, Docker build succeeds
✅ Push to ACR       — image pushed as build-id tag and latest
✅ Deploy to AKS     — KubernetesManifest deploys to production namespace
```

---

## Step 6 — Add Environment Approval Gate

1. **Environments** → `production` → **Approvals and checks**
2. **Add** → **Approvals**
3. Select approvers (your team leads)
4. Save

Now every deployment to production waits for manual approval.

---

## Step 7 — Verify Deployment on AKS

```bash
kubectl get pods -n production
kubectl get svc -n production
```

---

## Verification Checklist

✅ Pipeline triggers on push to `main`

✅ pytest runs and results published to Pipeline Tests tab

✅ Docker image pushed to ACR with `$(Build.BuildId)` tag

✅ KubernetesManifest deploys with new image tag

✅ Pods updated in AKS `production` namespace

✅ Environment approval gate (optional but recommended for prod)

---

## Troubleshooting

**Docker task fails — service connection error:**
- Verify ACR service connection is `Verified` in Project Settings → Service connections

**KubernetesManifest fails — cluster not found:**
- Confirm AKS cluster name and resource group in pipeline variables
- Ensure Azure Resource Manager service connection has Contributor on the AKS resource group

**Pipeline not triggering:**
- Verify `trigger: branches: include: - main` is at the top of the YAML
- Check that the YAML file path is correct in the pipeline definition

---

## Cleanup

```bash
# Delete Azure DevOps project resources (service connections, pipeline) from portal
# Delete AKS deployments
kubectl delete namespace production
```

---

## Key Learnings

- Azure Pipelines YAML (stages, jobs, tasks, dependsOn, conditions)
- Docker@2 task (build and push to ACR)
- KubernetesManifest@1 task (deploy manifests to AKS with image substitution)
- Azure service connections (ACR + ARM resource manager)
- PublishTestResults@2 (JUnit XML → Pipeline Tests tab)
- Environment approval gates (production deployment gating)
- `$(Build.BuildId)` for unique, traceable image tagging
- `condition: always()` for test result publishing on failure
- `strategy: runOnce` deployment strategy for AKS
- Azure Pipelines variables (pipeline-level and stage-level)
