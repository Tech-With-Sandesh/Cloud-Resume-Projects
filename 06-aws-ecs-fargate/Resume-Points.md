# Resume Points — Project 06: AWS ECS Fargate

---

## Fresher

- Deployed a containerised Python Flask application on AWS ECS Fargate with ECR private registry, ALB load balancing, and Application Auto Scaling based on CPU utilization (70% threshold).
- Built a production Docker image with non-root user, Docker HEALTHCHECK, gunicorn WSGI server, and ECR scan-on-push enabled for vulnerability detection.
- Configured ECS Fargate service in private subnets with awsvpc networking, ALB IP target type, and Security Group restricting container access to ALB only.
- Set deployment_minimum_healthy_percent=50 and deployment_maximum_percent=200 for zero-downtime rolling deployments.

---

## Experienced Cloud Engineer

- Architected a serverless container platform on ECS Fargate: ECR (private registry + scan-on-push) → ECS task definition (256 CPU/512MB, awsvpc, non-root, CloudWatch logs) → ALB (public subnets, IP target type) → Fargate tasks (private subnets) → Application Auto Scaling (CPU TargetTracking 70%, 2-6 tasks).
- Implemented Security Group chaining for Fargate: ALB SG allows 80 from internet; ECS task SG allows 5000 only from ALB SG ID — containers have no public IP and are unreachable directly.
- Configured Application Auto Scaling with TargetTrackingScaling (ECSServiceAverageCPUUtilization) targeting 70% — auto-scales from 2 to 6 tasks on traffic spikes without manual intervention.
- Used `lifecycle { ignore_changes = [task_definition] }` to allow CI/CD pipelines to update task definitions independently from Terraform state, preventing deployment conflicts.

---

## LinkedIn Project Description

Deployed a containerised Flask application on AWS ECS Fargate using Terraform — ECR (private registry, scan-on-push), ECS cluster with Container Insights, awsvpc task networking, ALB (IP target type, /health check), private subnet Fargate tasks, Application Auto Scaling (CPU 70% target tracking, 2-6 tasks), CloudWatch Logs streaming. Non-root Docker image with HEALTHCHECK and gunicorn WSGI. Security Group chaining: ALB → ECS tasks (port 5000 only, no internet).

---

## GitHub Project Description

AWS ECS Fargate App (Terraform) — ECR + ECS Cluster (Container Insights) + Fargate tasks (awsvpc, private subnets, non-root) + ALB (IP target type, health check) + Application Auto Scaling (CPU TargetTracking). CloudWatch Logs, Security Group chaining, rolling deployment config.

---

## How to Explain in an Interview (30 Seconds)

"I deployed a containerised application on ECS Fargate. The containers run in private subnets with no public IP — they're only reachable through the Application Load Balancer. The security group only allows traffic from the ALB security group ID, not from any IP range. Fargate pulls the image from ECR, and I enabled scan-on-push so every image is scanned for CVEs on upload. I added Application Auto Scaling with CPU target tracking at 70%, so when load increases, ECS automatically adds tasks up to 6, and scales back down when load drops."

---

## Skills Demonstrated

- Amazon ECS Fargate (serverless containers, awsvpc networking)
- Amazon ECR (private registry, scan-on-push, image lifecycle)
- ECS Task Definition (CPU/memory, container definitions, health checks)
- Application Load Balancer (IP target type for Fargate, /health check)
- Security Group chaining (ALB → ECS tasks, no direct internet)
- Application Auto Scaling (TargetTrackingScaling, ECS CPU metric)
- Docker (non-root user, HEALTHCHECK, gunicorn, multi-layer cache)
- CloudWatch Container Insights (ECS cluster monitoring)
- awslogs log driver (container log streaming to CloudWatch)
- Rolling deployment configuration (min/max healthy percent)
- ECR authentication workflow (get-login-password)
