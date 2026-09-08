# Resume Points — Project 02: AWS VPC Networking with 3-Tier Architecture

---

## Fresher

- Designed and provisioned a 3-tier AWS VPC (10.0.0.0/16) using Terraform — public subnets for web tier, private subnets for app and database tiers across 2 Availability Zones.
- Configured NAT Gateway in a public subnet with Elastic IP to allow private subnet instances outbound internet access while blocking all inbound connections.
- Built least-privilege Security Group chaining: Web SG allows 80/443 from internet; App SG allows 8080 only from Web SG ID; DB SG allows 3306 only from App SG ID — no direct internet access to backend tiers.
- Enabled VPC Flow Logs to CloudWatch Logs with a scoped IAM role for network traffic auditing and security monitoring.

---

## Experienced Cloud Engineer

- Architected a production-grade 3-tier VPC network on AWS using Terraform: IGW-attached public subnets (web/NAT tier), NAT-routed private subnets (app/db tier) across 2 AZs — all subnet CIDRs, route tables, and associations managed as code with zero hardcoded values.
- Implemented Security Group chaining using SG ID references (not CIDR blocks) for inter-tier traffic rules — ensuring that a compromised web server cannot bypass the firewall by spoofing an IP address, enforcing true identity-based access control between tiers.
- Configured VPC Flow Logs with a scoped IAM role (`vpc-flow-logs.amazonaws.com` trust), CloudWatch Log Group with 7-day retention, and `traffic_type = ALL` for complete inbound/outbound/rejected packet capture for compliance and incident forensics.
- Documented HA NAT Gateway pattern (one NAT per AZ), VPC Endpoints for S3/DynamoDB cost savings, and Network ACLs as stateless defence-in-depth alongside stateful Security Groups.

---

## LinkedIn Project Description

Designed and provisioned a 3-tier AWS VPC architecture using Terraform — public subnets (web/NAT), private subnets (app/DB) across 2 AZs. Implemented Security Group chaining with SG ID references for least-privilege inter-tier access (no CIDR-based rules between tiers). Enabled VPC Flow Logs to CloudWatch for traffic auditing. Documented HA NAT Gateway (one per AZ), VPC Endpoints for S3/DynamoDB, and Network ACLs as production upgrade paths.

---

## GitHub Project Description

AWS VPC 3-Tier Architecture (Terraform) — VPC, public/private subnets across 2 AZs, IGW, NAT Gateway with EIP, route tables, Security Group chaining (web→app→db with SG ID references), VPC Flow Logs to CloudWatch. Production patterns: HA NAT, VPC Endpoints, NACLs, remote state.

---

## How to Explain in an Interview (30 Seconds)

"I built a 3-tier VPC on AWS using Terraform. The design separates web, app, and database tiers into public and private subnets. The security group design is the most important part — instead of using IP CIDR ranges between tiers, I reference security group IDs. So the app tier only accepts traffic from resources that belong to the web security group, not from any IP in a CIDR range. This is identity-based access control within the VPC. I also enabled VPC Flow Logs to CloudWatch so every accepted and rejected packet is captured for audit and forensics."

---

## Skills Demonstrated

- AWS VPC (CIDR planning, subnets, IGW, NAT Gateway, route tables)
- Security Group chaining (SG ID references vs CIDR blocks)
- 3-tier network architecture (web/app/db separation)
- NAT Gateway (outbound-only internet for private subnets)
- VPC Flow Logs (CloudWatch, IAM role scoping, retention policy)
- Terraform (resources, variables, outputs, tfvars)
- High Availability (multi-AZ subnet design)
- AWS Elastic IP (static NAT Gateway IP)
- VPC Endpoints (S3/DynamoDB — production cost optimisation)
- Network ACLs (stateless defence-in-depth)
