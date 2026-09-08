# Project 08 - AWS CodePipeline CI/CD: GitHub → CodeBuild → ECR → ECS

## Problem Statement

Your team needs a fully managed CI/CD pipeline that:
- Triggers automatically on every GitHub push to `main`
- Runs unit tests before building
- Builds and pushes Docker images to ECR
- Deploys to ECS Fargate automatically
- Requires zero Jenkins servers to manage

Build an end-to-end CI/CD pipeline using AWS-native services: CodePipeline + CodeBuild + ECR + ECS.

---

## Architecture

```
Developer → git push → GitHub (main branch)
                │
                ▼ (CodeStar Connection webhook)
         CodePipeline
                │
    ┌───────────┼───────────────┐
    ▼           ▼               ▼
  Source      Build           Deploy
(GitHub)   (CodeBuild)        (ECS)
              │
    ┌─────────┼──────────┐
    ▼         ▼          ▼
  Install   pytest     docker build
  deps      tests      docker push → ECR
              │               │
              │         imagedefinitions.json
              └──────────────►│
                              ▼
                      ECS Service Update
                      (rolling deployment)
```

---

## Project Structure

```
08-aws-codepipeline-cicd/
├── buildspec/
│   └── buildspec.yml    ← CodeBuild phases: install→test→build→push→artifact
└── terraform/
    ├── main.tf          ← CodePipeline, CodeBuild, ECR, S3 artifacts, IAM, CodeStar
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## Prerequisites

| Tool | Notes |
|------|-------|
| Terraform | ≥ 1.3.0 |
| AWS CLI | ≥ 2.0 |
| GitHub account | For source repository |
| Existing ECS Fargate service | From Project 06 |

---

## Step 1 — Update terraform.tfvars

```hcl
github_repo      = "your-username/your-app-repo"
github_branch    = "main"
ecs_cluster_name = "ecs-fargate-app-cluster"
ecs_service_name = "ecs-fargate-app-service"
```

---

## Step 2 — Deploy Pipeline Infrastructure

```bash
cd terraform/
terraform init
terraform apply
```

---

## Step 3 — Activate GitHub Connection

After `terraform apply`, the CodeStar GitHub connection is in **Pending** state.

1. Go to **AWS Console → Developer Tools → Settings → Connections**
2. Find `cloud-cicd-github` → Status: `Pending`
3. Click **Update pending connection**
4. Click **Install a new app** → Authorize AWS Connector on your GitHub account
5. Select repositories → Save
6. Connection status changes to **Available**

> ⚠️ This step requires a manual browser action — it cannot be automated by Terraform.

---

## Step 4 — Store Docker Hub Credentials in SSM (optional)

If your buildspec uses Docker Hub:

```bash
aws ssm put-parameter \
  --name "/codepipeline/docker-hub-username" \
  --value "your-dockerhub-username" \
  --type "SecureString"

aws ssm put-parameter \
  --name "/codepipeline/docker-hub-password" \
  --value "your-dockerhub-token" \
  --type "SecureString"
```

---

## Step 5 — Add buildspec.yml to Your Application Repository

Copy `buildspec/buildspec.yml` to the root of your application repository.

Your repo should have:

```
your-app-repo/
├── buildspec/
│   └── buildspec.yml
├── app.py
├── requirements.txt
├── Dockerfile
└── tests/
    └── test_app.py
```

---

## Step 6 — Trigger the Pipeline

```bash
git add .
git commit -m "feat: add CI/CD pipeline configuration"
git push origin main
```

Go to **CodePipeline → cloud-cicd-pipeline** and watch:

```
Source   → ✅ Succeeded
Build    → 🔄 In Progress...
Deploy   → ⏳ Waiting...
```

---

## Step 7 — Monitor CodeBuild Logs

```bash
aws logs tail /aws/codebuild/cloud-cicd-build --follow
```

Or in Console: **CodeBuild → Build projects → cloud-cicd-build → Build history → Logs**

Expected build output:

```
=== Installing dependencies ===
=== Running tests ===
PASSED tests/test_app.py::test_health
=== Logging into ECR ===
Login Succeeded
=== Building Docker image ===
Successfully built abc123def456
=== Pushing to ECR ===
latest: digest: sha256:...
=== Writing imagedefinitions.json ===
[{"name":"cloud-cicd","imageUri":"123456.dkr.ecr.ap-south-1.amazonaws.com/cloud-cicd-app:a1b2c3d4"}]
```

---

## Step 8 — Verify ECS Deployment

```bash
aws ecs describe-services \
  --cluster ecs-fargate-app-cluster \
  --services ecs-fargate-app-service \
  --query 'services[0].{Status:status,Desired:desiredCount,Running:runningCount}'
```

Expected:

```json
{
  "Status": "ACTIVE",
  "Desired": 2,
  "Running": 2
}
```

---

## Verification Checklist

✅ CodeStar Connection status: `Available`

✅ Pipeline created with 3 stages: Source → Build → Deploy

✅ Push to `main` branch triggers pipeline automatically

✅ CodeBuild: tests pass, Docker image built and pushed to ECR

✅ `imagedefinitions.json` artifact created with correct image URI + tag

✅ ECS service updated with new task definition

✅ ECS tasks running the new image (check container image in task detail)

---

## Troubleshooting

**Pipeline stuck at Source — `Connection not found`:**
- Complete the GitHub connection activation in Step 3

**CodeBuild fails — `cannot connect to Docker daemon`:**
- Ensure `privileged_mode = true` in CodeBuild environment (required for Docker builds)

**Deploy stage fails — `Service not found`:**
- Verify `ecs_cluster_name` and `ecs_service_name` match exactly in tfvars

**Tests fail at pre_build:**
- Check `requirements.txt` includes `pytest`
- Verify test file paths in `tests/` directory

---

## Cleanup

```bash
cd terraform/
terraform destroy
```

---

## Key Learnings

- AWS CodePipeline (3-stage pipeline: Source → Build → Deploy)
- AWS CodeBuild (buildspec.yml phases, privileged_mode for Docker)
- CodeStar Connections (GitHub OAuth integration — pending → available)
- `imagedefinitions.json` artifact format (ECS deployment contract)
- S3 artifact bucket (pipeline stage data exchange)
- SSM Parameter Store for secrets in buildspec (SecureString)
- ECR push from CodeBuild (IAM permissions + get-login-password)
- ECS rolling deployment triggered by CodePipeline
- CodeBuild cache (pip cache for faster builds)
- Git SHA image tagging (`CODEBUILD_RESOLVED_SOURCE_VERSION`)
