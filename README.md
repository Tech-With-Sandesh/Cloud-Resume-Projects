# Cloud Projects — 30 Real-World Hands-On Cloud Projects

> **12 AWS · 10 Azure · 8 GCP** — Complete source code, IaC files, step-by-step setup, and resume points for every project.

---

## Project Index

### ☁️ AWS Projects (01–12)

| # | Project | Services | Difficulty |
|---|---------|----------|-----------|
| [01](./01-aws-s3-static-website/) | S3 Static Website with CloudFront CDN + HTTPS | S3, CloudFront, ACM, Route 53 | Beginner |
| [02](./02-aws-vpc-networking/) | VPC 3-Tier Architecture | VPC, Subnets, NAT, Security Groups, Flow Logs | Beginner |
| [03](./03-aws-rds-mysql/) | RDS MySQL with Multi-AZ + Backups | RDS, Parameter Groups, CloudWatch Logs | Intermediate |
| [04](./04-aws-lambda-api/) | Lambda Serverless REST API | Lambda, API Gateway, DynamoDB | Intermediate |
| [05](./05-aws-cloudfront-cdn/) | CloudFront CDN with Security Headers | CloudFront, S3, OAC, Response Headers Policy | Intermediate |
| [06](./06-aws-ecs-fargate/) | ECS Fargate Containerised App | ECS, ECR, ALB, Auto Scaling | Intermediate |
| [07](./07-aws-eks-microservices/) | EKS Microservices with Ingress + HPA | EKS, NGINX Ingress, HPA, Metrics Server | Advanced |
| [08](./08-aws-codepipeline-cicd/) | CodePipeline CI/CD | CodePipeline, CodeBuild, ECR, ECS, CodeStar | Advanced |
| [09](./09-aws-sns-sqs-messaging/) | SNS + SQS Event-Driven Messaging | SNS, SQS, DLQ, Lambda | Intermediate |
| [10](./10-aws-cloudwatch-monitoring/) | CloudWatch Monitoring + Alerts | CloudWatch, SNS, Log Metric Filter, Dashboard | Intermediate |
| [11](./11-aws-iam-security/) | IAM Security: Least Privilege + MFA + Cross-Account | IAM, STS, MFA, SCPs | Advanced |
| [12](./12-aws-serverless-data-pipeline/) | Serverless Data Pipeline | S3, Lambda, Athena, Lifecycle | Advanced |

---

### 🔷 Azure Projects (13–22)

| # | Project | Services | Difficulty |
|---|---------|----------|-----------|
| [13](./13-azure-vm-nginx/) | Azure VM with Nginx (Bicep) | Azure VM, NSG, Custom Script Extension | Beginner |
| [14](./14-azure-blob-static-website/) | Azure Blob Static Website + Azure CDN | Blob Storage, Azure CDN | Beginner |
| [15](./15-azure-aks-kubernetes/) | AKS Kubernetes + ACR + Container Insights | AKS, ACR, Log Analytics, Managed Identity | Advanced |
| [16](./16-azure-devops-cicd/) | Azure DevOps CI/CD Pipeline | Azure Pipelines, ACR, AKS, Environments | Advanced |
| [17](./17-azure-functions-serverless/) | Azure Functions Serverless API | Azure Functions, App Insights, Consumption Plan | Intermediate |
| [18](./18-azure-sql-database/) | Azure SQL with AAD Auth + Auditing | Azure SQL, AAD Auth, Threat Detection | Intermediate |
| [19](./19-azure-monitor-alerts/) | Azure Monitor: Alerts + KQL | Azure Monitor, Log Analytics, Action Groups | Intermediate |
| [20](./20-azure-vnet-peering/) | Azure VNet Hub-Spoke Peering | VNet, Peering, NSG, Hub-Spoke | Intermediate |
| [21](./21-azure-container-registry/) | Azure Container Registry + ACI | ACR, ACI, Managed Identity, AcrPull | Intermediate |
| [22](./22-azure-key-vault-secrets/) | Azure Key Vault Secrets Management | Key Vault, RBAC, Managed Identity, Audit Logs | Advanced |

---

### 🟡 GCP Projects (23–30)

| # | Project | Services | Difficulty |
|---|---------|----------|-----------|
| [23](./23-gcp-gke-kubernetes/) | GKE Kubernetes + Workload Identity | GKE, VPC-native, Cluster Autoscaler | Advanced |
| [24](./24-gcp-cloud-run-serverless/) | Cloud Run Serverless Container | Cloud Run, Artifact Registry, scale-to-zero | Intermediate |
| [25](./25-gcp-cloudsql-postgres/) | Cloud SQL PostgreSQL + Private IP | Cloud SQL, VPC Peering, Query Insights, PITR | Intermediate |
| [26](./26-gcp-pubsub-dataflow/) | Pub/Sub Event Streaming + DLQ | Pub/Sub, DLQ, retry policy, fan-out | Intermediate |
| [27](./27-gcp-cloud-storage-cdn/) | Cloud Storage + Cloud CDN + LB | GCS, Cloud CDN, Global LB | Beginner |
| [28](./28-gcp-cloudbuild-cicd/) | Cloud Build CI/CD Pipeline | Cloud Build, Artifact Registry, Cloud Run | Advanced |
| [29](./29-gcp-monitoring-logging/) | Cloud Monitoring + Log Sinks | Cloud Monitoring, Log-based metrics, Sinks | Intermediate |
| [30](./30-gcp-vpc-multi-region/) | GCP Global VPC Multi-Region | VPC, Cloud NAT, IAP, VPC Flow Logs | Advanced |

---

## Each Project Includes

```
project-folder/
├── README.md           ← Problem statement, architecture, step-by-step setup
├── Resume-Points.md    ← Fresher & experienced bullet points, interview answer
├── terraform/          ← Complete Terraform (main.tf, variables.tf, outputs.tf)
│   └── terraform.tfvars
├── kubernetes/         ← K8s YAML manifests (for K8s projects)
├── source-code/        ← Application code (Python, HTML/CSS)
├── app/                ← Dockerised app (Dockerfile, requirements.txt)
├── scripts/            ← Shell scripts (Azure Custom Script Extension etc.)
├── cloudbuild/         ← Cloud Build YAML (GCP CI/CD)
├── pipelines/          ← Azure Pipelines YAML (Azure CI/CD)
└── policies/           ← IAM JSON policies (AWS IAM projects)
```

---

## Tools Used Across Projects

| Tool | Used In |
|------|---------|
| Terraform (HCL) | AWS 01-12, Azure 15,17-22, GCP 23-30 |
| Azure Bicep | Azure 13 |
| AWS CLI | AWS projects |
| Azure CLI | Azure projects |
| gcloud CLI | GCP projects |
| Docker | Projects 06, 07, 15, 21, 24, 28 |
| kubectl | Projects 07, 15, 23 |
| Helm | Project 07 |
| Python | Projects 04, 12, 17, 24, 26 |

---

## Prerequisites by Cloud Provider

### AWS
```bash
aws configure          # Set Access Key, Secret Key, Region
aws sts get-caller-identity  # Verify
terraform init         # In each project's terraform/ folder
```

### Azure
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
terraform init         # In each project's terraform/ folder
```

### GCP
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
terraform init         # In each project's terraform/ folder
```

---

## Cost Awareness

> ⚠️ Always run `terraform destroy` after completing each project to avoid unexpected charges.

| Project | Estimated Daily Cost |
|---------|---------------------|
| S3 / Blob / GCS static sites | < $0.01 |
| Lambda / Functions / Cloud Run | < $0.01 (free tier) |
| RDS db.t3.micro | ~$0.50/day |
| EKS / AKS / GKE cluster | $2–5/day |
| NAT Gateway (AWS) | ~$1/day |
| Cloud Run (scale-to-zero) | $0 when idle |

---

## How to Use These Projects

1. **Read the README** — understand the problem statement and architecture
2. **Follow the steps** — each step has expected output for verification  
3. **Check the Verification Checklist** — confirm everything works
4. **Read Resume-Points.md** — prepare to talk about this in interviews
5. **Clean up** — run `terraform destroy` or `az group delete` to avoid charges

---

*Happy Cloud Building! 🚀*
