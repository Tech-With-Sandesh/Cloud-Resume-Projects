# Project 06 - AWS ECS Fargate Containerised Application with ALB and Auto Scaling

## Problem Statement

Your team needs to deploy a containerised Python application with:
- No EC2 instances to manage (serverless containers)
- Automatic horizontal scaling based on CPU usage
- Load balancing across multiple container instances
- Private container image registry
- Container health checks and rolling deployments
- Centralised container logs

Build a production ECS Fargate service with ECR, ALB, and Auto Scaling using Terraform.

---

## Architecture

```
Internet
  │
  ▼ HTTP :80
Application Load Balancer (public subnets)
  │  ← /health check (healthy threshold: 2)
  ▼ Port 5000
ECS Fargate Tasks (private subnets — awsvpc networking)
  ├── Task 1 (ap-south-1a)
  └── Task 2 (ap-south-1b)
        │
        ├── ECR (Docker image pull)
        └── CloudWatch Logs (/ecs/ecs-fargate-app)

Auto Scaling: CPU > 70% → scale out (max 6 tasks)
              CPU < 70% → scale in  (min 2 tasks)
```

---

## Project Structure

```
06-aws-ecs-fargate/
├── app/
│   ├── app.py           ← Flask app (/health, /ready, / endpoints)
│   ├── Dockerfile       ← Non-root user, HEALTHCHECK, gunicorn
│   └── requirements.txt ← flask==3.0.3, gunicorn==22.0.0
└── terraform/
    ├── main.tf          ← ECR, ECS cluster, task def, ALB, service, auto scaling
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.3.0 |
| AWS CLI | ≥ 2.0 |
| Docker | ≥ 24.0 |
| Existing VPC | Project 02 VPC (or any VPC with public/private subnets) |

---

## Step 1 — Update terraform.tfvars

```hcl
vpc_id             = "vpc-0abc123"
public_subnet_ids  = ["subnet-0aaa", "subnet-0bbb"]
private_subnet_ids = ["subnet-0ccc", "subnet-0ddd"]
```

---

## Step 2 — Deploy Infrastructure

```bash
cd terraform/
terraform init
terraform apply
```

Copy the ECR URL from output:

```
ecr_repository_url = "123456789012.dkr.ecr.ap-south-1.amazonaws.com/ecs-fargate-app"
```

---

## Step 3 — Build and Push Docker Image

```bash
# Set variables
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-south-1"
ECR_URL="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/ecs-fargate-app"

# Authenticate to ECR
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# Build image
cd app/
docker build -t ecs-fargate-app .

# Tag and push
docker tag ecs-fargate-app:latest "$ECR_URL:latest"
docker push "$ECR_URL:latest"
```

---

## Step 4 — Force ECS Service Update

```bash
aws ecs update-service \
  --cluster ecs-fargate-app-cluster \
  --service ecs-fargate-app-service \
  --force-new-deployment
```

Watch tasks start:

```bash
aws ecs list-tasks --cluster ecs-fargate-app-cluster
```

---

## Step 5 — Test the Application

```bash
ALB=$(cd terraform/ && terraform output -raw alb_dns_name)

# Health check
curl "http://$ALB/health"
# Expected: {"status": "healthy", "service": "ecs-fargate-app"}

# Main endpoint
curl "http://$ALB/"
# Expected: {"message": "Hello from ECS Fargate!", "hostname": "...", "environment": "prod"}
```

---

## Step 6 — View CloudWatch Logs

```bash
aws logs tail /ecs/ecs-fargate-app --follow
```

---

## Verification Checklist

✅ ECR repository created with scan-on-push enabled

✅ Docker image pushed to ECR

✅ ECS Fargate tasks in `RUNNING` state

✅ ALB health checks passing (target group: healthy)

✅ Application accessible at `http://<alb-dns-name>`

✅ `/health` returns 200

✅ Auto Scaling target registered (CPU target: 70%)

✅ CloudWatch Logs streaming from containers

---

## Troubleshooting

**Tasks stuck in `PENDING`:**
- Check ECR image URL in task definition matches pushed image
- Verify task execution role has ECR pull permissions

**ALB health check `unhealthy`:**
- Check `/health` endpoint returns 200 in container
- Verify Security Group allows port 5000 from ALB SG

**`CannotPullContainerError`:**
- Confirm NAT Gateway exists (Fargate in private subnets needs NAT to pull from ECR)
- Check ECR authentication token is valid

---

## Cleanup

```bash
# Scale down service first
aws ecs update-service --cluster ecs-fargate-app-cluster \
  --service ecs-fargate-app-service --desired-count 0

# Destroy infrastructure
cd terraform/
terraform destroy
```

---

## Key Learnings

- Amazon ECR (private registry, scan-on-push, image tagging)
- ECS Fargate task definition (cpu, memory, awsvpc, container definitions)
- ECS Fargate service (desired count, health percent, rolling deployment)
- Application Load Balancer with IP target type (required for Fargate awsvpc)
- ECS task Security Group (allow only from ALB SG — not internet)
- Container health checks (Docker HEALTHCHECK + ECS health check)
- CloudWatch Logs with awslogs driver
- Application Auto Scaling with CPU TargetTrackingScaling
- ECR authentication (`get-login-password` + docker login)
- Non-root Docker containers (user appuser)
- `lifecycle { ignore_changes = [task_definition] }` (CI/CD compatibility)
