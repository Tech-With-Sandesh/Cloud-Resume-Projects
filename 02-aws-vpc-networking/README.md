# Project 02 - AWS VPC Networking with 3-Tier Architecture

## Problem Statement

Your company needs a secure, production-ready network foundation on AWS.

Requirements:
- Isolated network for web, app, and database tiers
- Private subnets for backend and DB (no direct internet access)
- NAT Gateway for outbound internet from private subnets
- Least-privilege Security Groups between tiers
- VPC Flow Logs for network traffic auditing

Build a complete 3-tier VPC architecture using Terraform.

---

## Architecture

```
Internet
    │
    ▼
Internet Gateway
    │
┌───▼──────────────────────────────────────┐
│               VPC (10.0.0.0/16)          │
│                                          │
│  ┌─────────────────────────────────┐     │
│  │   Public Subnets                │     │
│  │   10.0.1.0/24  (ap-south-1a)   │     │
│  │   10.0.2.0/24  (ap-south-1b)   │     │
│  │                                 │     │
│  │   [Web Tier SG]  [NAT Gateway] │     │
│  └────────────┬────────────────────┘     │
│               │ (SG reference — port 8080)│
│  ┌────────────▼────────────────────┐     │
│  │   Private Subnets               │     │
│  │   10.0.3.0/24  (ap-south-1a)   │     │
│  │   10.0.4.0/24  (ap-south-1b)   │     │
│  │                                 │     │
│  │   [App Tier SG]                │     │
│  └────────────┬────────────────────┘     │
│               │ (SG reference — port 3306)│
│  ┌────────────▼────────────────────┐     │
│  │   [DB Tier SG] — MySQL 3306    │     │
│  └─────────────────────────────────┘     │
│                                          │
│   VPC Flow Logs → CloudWatch Logs        │
└──────────────────────────────────────────┘
```

---

## Project Structure

```
02-aws-vpc-networking/
└── terraform/
    ├── main.tf          ← VPC, subnets, IGW, NAT, route tables, SGs, flow logs
    ├── variables.tf     ← All typed variables with defaults
    ├── outputs.tf       ← VPC ID, subnet IDs, SG IDs, NAT IP
    └── terraform.tfvars ← Environment-specific values
```

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | ≥ 1.3.0 | [hashicorp.com](https://developer.hashicorp.com/terraform/install) |
| AWS CLI | ≥ 2.0 | [aws.amazon.com](https://aws.amazon.com/cli/) |

---

## Step 1 — Configure AWS CLI

```bash
aws configure
```

Enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `ap-south-1`
- Default output format: `json`

Verify:

```bash
aws sts get-caller-identity
```

Expected:

```json
{
  "UserId": "AIDA...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/your-user"
}
```

---

## Step 2 — Review and Update Variables

```bash
cd terraform/
```

Open `terraform.tfvars` and verify settings:

```hcl
aws_region   = "ap-south-1"
project_name = "cloud-vpc"
environment  = "dev"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
```

> ℹ️ The CIDR ranges are designed for a 3-tier architecture. Public subnets host web servers and NAT Gateway; private subnets host app servers and databases.

---

## Step 3 — Initialize Terraform

```bash
terraform init
```

Expected:

```
Terraform has been successfully initialized!
```

---

## Step 4 — Validate and Plan

```bash
terraform validate
terraform plan
```

Expected plan summary:

```
Plan: 20 to add, 0 to change, 0 to destroy.
```

Key resources in plan:
- 1 VPC
- 1 Internet Gateway
- 4 Subnets (2 public, 2 private)
- 1 Elastic IP
- 1 NAT Gateway
- 2 Route Tables + Associations
- 3 Security Groups (web, app, db)
- 1 CloudWatch Log Group
- 1 IAM Role + Policy (flow logs)
- 1 VPC Flow Log

---

## Step 5 — Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

> ⚠️ NAT Gateway takes 2–3 minutes to become available.

Expected outputs:

```
vpc_id                = "vpc-0abc123def456"
public_subnet_ids     = ["subnet-0aaa", "subnet-0bbb"]
private_subnet_ids    = ["subnet-0ccc", "subnet-0ddd"]
nat_gateway_id        = "nat-0xyz789"
nat_public_ip         = "13.234.XX.XX"
web_security_group_id = "sg-0111"
app_security_group_id = "sg-0222"
db_security_group_id  = "sg-0333"
flow_log_group        = "/aws/vpc/cloud-vpc-flow-logs"
```

---

## Step 6 — Verify the VPC in AWS Console

1. Go to **VPC** → **Your VPCs**
2. Find `cloud-vpc-vpc` → verify CIDR `10.0.0.0/16`
3. Go to **Subnets** → verify 4 subnets (2 public, 2 private)
4. Go to **Route Tables** → verify public RT has IGW route, private RT has NAT route
5. Go to **NAT Gateways** → verify `Available` state
6. Go to **Security Groups** → verify 3 SGs (web, app, db)

---

## Step 7 — Verify Security Group Rules

```bash
# Get security group IDs from Terraform output
terraform output web_security_group_id
terraform output app_security_group_id
terraform output db_security_group_id
```

Verify web SG allows 80/443 from 0.0.0.0/0:

```bash
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw web_security_group_id) \
  --query 'SecurityGroups[0].IpPermissions'
```

Verify app SG only allows port 8080 from web SG (not from internet):

```bash
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw app_security_group_id) \
  --query 'SecurityGroups[0].IpPermissions'
```

Expected — `UserIdGroupPairs` shows web SG ID, not `0.0.0.0/0`:

```json
[{
  "FromPort": 8080,
  "IpProtocol": "tcp",
  "UserIdGroupPairs": [{"GroupId": "sg-0111"}]
}]
```

---

## Step 8 — Verify VPC Flow Logs

```bash
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/vpc/cloud-vpc"
```

Expected:

```json
{
  "logGroups": [{
    "logGroupName": "/aws/vpc/cloud-vpc-flow-logs",
    "retentionInDays": 7
  }]
}
```

After launching an EC2 instance in the VPC, flow logs appear in:

```
CloudWatch → Log Groups → /aws/vpc/cloud-vpc-flow-logs
```

---

## Verification Checklist

✅ VPC created with CIDR `10.0.0.0/16`

✅ 2 public subnets (map_public_ip_on_launch = true)

✅ 2 private subnets (no public IP mapping)

✅ Internet Gateway attached to VPC

✅ NAT Gateway in public subnet — status `Available`

✅ Public route table → IGW route for `0.0.0.0/0`

✅ Private route table → NAT Gateway route for `0.0.0.0/0`

✅ Web SG: allows 80, 443 from internet

✅ App SG: allows 8080 from web SG only (no internet)

✅ DB SG: allows 3306 from app SG only (no internet)

✅ VPC Flow Logs → CloudWatch Log Group created

---

## Troubleshooting

**`NAT gateway in state: pending`:**
- Wait 2–3 minutes and re-run `terraform apply` — it is provisioning

**Private instances can't reach the internet:**
- Verify private route table has `0.0.0.0/0 → nat-xxxxxx` (not IGW)
- Verify NAT Gateway is in public subnet and in `Available` state

**Security Group rule not working:**
- Ensure the SG reference uses the SG ID (not CIDR) for inter-tier rules
- Check the `from_port` and `to_port` match your application port exactly

---

## Cleanup

```bash
cd terraform/
terraform destroy
```

Type `yes` when prompted.

> ⚠️ NAT Gateway charges approximately $0.045/hour even when idle. Always destroy when not in use.

---

## Production Notes

> **1. Use Multiple NAT Gateways for HA**
> One NAT per AZ prevents cross-AZ data transfer costs and eliminates single-AZ failure:
> ```hcl
> resource "aws_nat_gateway" "main" {
>   count         = length(var.public_subnet_cidrs)
>   allocation_id = aws_eip.nat[count.index].id
>   subnet_id     = aws_subnet.public[count.index].id
> }
> ```

> **2. Enable VPC Endpoints (S3, DynamoDB)**
> Route S3/DynamoDB traffic through private VPC endpoints — no NAT Gateway costs for AWS service traffic.

> **3. Use Network ACLs as Defence-in-Depth**
> Add NACLs at the subnet level as a stateless second layer of traffic control (SGs are stateful/first layer).

> **4. Enable Terraform Remote State**
> ```hcl
> backend "s3" {
>   bucket         = "my-tfstate-bucket"
>   key            = "vpc/terraform.tfstate"
>   region         = "ap-south-1"
>   dynamodb_table = "terraform-lock"
> }
> ```

---

## Key Learnings

- VPC CIDR planning (10.0.0.0/16 → /24 subnets per AZ)
- Public vs private subnet design (map_public_ip_on_launch)
- Internet Gateway vs NAT Gateway (inbound vs outbound)
- Route table design (public → IGW, private → NAT)
- Security Group chaining (SG references vs CIDR blocks)
- 3-tier security group architecture (web → app → db, least-privilege)
- VPC Flow Logs with CloudWatch (IAM role + log group)
- NAT Gateway cost awareness (per AZ, per GB)
- VPC Endpoints for S3/DynamoDB (production cost saving)
- Network ACLs vs Security Groups (stateless vs stateful)
