# Project 03 - AWS RDS MySQL with Multi-AZ, Encryption & Automated Backups

## Problem Statement

Your application needs a managed relational database with:
- No manual patching or OS management
- Automated daily backups with point-in-time recovery
- Encryption at rest and in transit
- High availability with Multi-AZ failover
- Slow query logging for performance tuning
- Private access only (no public exposure)

Build a production-ready MySQL database using Amazon RDS.

---

## Architecture

```
Application (EC2 / ECS in private subnet)
      │
      ▼ Port 3306 (MySQL)
RDS Security Group (allows 3306 from app subnet CIDR only)
      │
      ▼
RDS MySQL 8.0 (Primary — ap-south-1a)
      │  ← Synchronous replication
      ▼
RDS MySQL 8.0 (Standby — ap-south-1b) [Multi-AZ]
      │
      ▼
DB Subnet Group (private subnets across 2 AZs)

Automated Backups → S3 (AWS managed, 7-day retention)
CloudWatch Logs  → audit, error, general, slowquery logs
```

---

## Project Structure

```
03-aws-rds-mysql/
└── terraform/
    ├── main.tf          ← RDS instance, subnet group, SG, parameter group
    ├── variables.tf     ← All typed variables (password is sensitive)
    ├── outputs.tf       ← Endpoint, hostname, port, ARN
    └── terraform.tfvars ← Environment values (password via env var)
```

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | ≥ 1.3.0 | [hashicorp.com](https://developer.hashicorp.com/terraform/install) |
| AWS CLI | ≥ 2.0 | [aws.amazon.com](https://aws.amazon.com/cli/) |
| Existing VPC | Project 02 VPC | Run Project 02 first |

---

## Step 1 — Set Database Password via Environment Variable

> ⚠️ **Never store passwords in `terraform.tfvars` or commit them to Git.**

```bash
export TF_VAR_db_password="YourSecurePassword123!"
```

Verify it is set:

```bash
echo $TF_VAR_db_password
```

---

## Step 2 — Update terraform.tfvars

```bash
cd terraform/
```

Edit `terraform.tfvars`:

```hcl
vpc_name        = "cloud-vpc-vpc"   # Name tag of your VPC from Project 02
app_subnet_cidr = "10.0.3.0/24"    # CIDR of your app subnet
```

For production, enable:

```hcl
multi_az            = true
deletion_protection = true
skip_final_snapshot = false
```

---

## Step 3 — Initialize and Apply

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

> ⚠️ RDS provisioning takes **5–10 minutes**.

Expected outputs:

```
rds_endpoint   = "cloud-rds-mysql.abc123.ap-south-1.rds.amazonaws.com:3306"
rds_hostname   = "cloud-rds-mysql.abc123.ap-south-1.rds.amazonaws.com"
rds_port       = 3306
rds_db_name    = "appdb"
```

---

## Step 4 — Connect to RDS from an EC2 Instance

Launch a test EC2 instance in the same VPC private subnet, then SSH into it:

```bash
# Install MySQL client
sudo apt update && sudo apt install -y mysql-client

# Connect to RDS
mysql -h $(terraform output -raw rds_hostname) \
      -P 3306 \
      -u admin \
      -p
```

Enter your password when prompted.

Expected — MySQL prompt:

```
Welcome to the MySQL monitor.
mysql>
```

---

## Step 5 — Test Database Operations

```sql
-- Show existing databases
SHOW DATABASES;

-- Use the app database
USE appdb;

-- Create a test table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');
INSERT INTO users (name, email) VALUES ('Bob', 'bob@example.com');

-- Query data
SELECT * FROM users;
```

Expected:

```
+----+-------+-------------------+---------------------+
| id | name  | email             | created_at          |
+----+-------+-------------------+---------------------+
|  1 | Alice | alice@example.com | 2024-01-15 10:30:00 |
|  2 | Bob   | bob@example.com   | 2024-01-15 10:30:01 |
+----+-------+-------------------+---------------------+
```

---

## Step 6 — Verify Automated Backups

```bash
aws rds describe-db-instance-automated-backups \
  --db-instance-identifier cloud-rds-mysql \
  --query 'DBInstanceAutomatedBackups[0].{Status:Status,Retention:BackupRetentionPeriod}'
```

Expected:

```json
{
  "Status": "active",
  "Retention": 7
}
```

---

## Step 7 — Verify Encryption

```bash
aws rds describe-db-instances \
  --db-instance-identifier cloud-rds-mysql \
  --query 'DBInstances[0].{Encrypted:StorageEncrypted,Engine:Engine,Version:EngineVersion}'
```

Expected:

```json
{
  "Encrypted": true,
  "Engine": "mysql",
  "Version": "8.0.35"
}
```

---

## Step 8 — View CloudWatch Logs (Slow Query)

```bash
aws logs describe-log-streams \
  --log-group-name "/aws/rds/instance/cloud-rds-mysql/slowquery" \
  --query 'logStreams[*].logStreamName'
```

---

## Verification Checklist

✅ RDS instance status: `available`

✅ Endpoint accessible from app subnet (port 3306)

✅ `publicly_accessible = false` confirmed

✅ `storage_encrypted = true` confirmed

✅ Automated backups: 7-day retention

✅ Parameter group applied (utf8mb4, slow query log)

✅ CloudWatch Logs: audit/error/general/slowquery exports enabled

✅ MySQL connection successful from EC2 in private subnet

✅ CRUD operations working on `appdb`

---

## Troubleshooting

**`Can't connect to MySQL server` from EC2:**
- Verify EC2 is in the same VPC
- Check Security Group allows port 3306 from the EC2's subnet CIDR
- Verify `publicly_accessible = false` (use private endpoint, not public)

**`Access denied for user 'admin'`:**
- Double-check the password matches `TF_VAR_db_password`
- Ensure you're connecting to the correct hostname

**RDS creation fails with `InvalidSubnet`:**
- Ensure DB Subnet Group has subnets in at least 2 different AZs
- Check that referenced VPC and subnet tags match `terraform.tfvars`

---

## Cleanup

```bash
cd terraform/
terraform destroy
```

> ⚠️ If `deletion_protection = true`, first set it to `false`:
> ```bash
> terraform apply -var="deletion_protection=false"
> terraform destroy
> ```

---

## Production Notes

> **1. Use AWS Secrets Manager for Credentials**
> ```hcl
> resource "aws_secretsmanager_secret" "db_password" { name = "rds/mysql/password" }
> ```
> Application fetches credentials at runtime via SDK — no passwords in environment variables.

> **2. Enable Multi-AZ for HA**
> Set `multi_az = true` — RDS synchronously replicates to standby in second AZ.
> Automatic failover in 60–120 seconds if primary AZ fails.

> **3. Enable Read Replicas for Read Scaling**
> ```hcl
> resource "aws_db_instance" "replica" {
>   replicate_source_db = aws_db_instance.mysql.identifier
> }
> ```

> **4. Use RDS Proxy for Connection Pooling**
> For Lambda or containerised apps with high connection counts, use RDS Proxy to pool and reuse database connections.

---

## Key Learnings

- Amazon RDS MySQL provisioning (engine, version, instance class, storage)
- DB Subnet Group (multi-AZ subnet coverage requirement)
- RDS Security Group (port 3306, restricted to app subnet — not public)
- `storage_encrypted = true` (AWS KMS encryption at rest)
- Automated backups (backup_window, backup_retention_period)
- Maintenance window (auto minor version upgrade)
- CloudWatch Logs export (audit, error, general, slowquery)
- Parameter Group (utf8mb4, slow_query_log, long_query_time)
- `sensitive = true` for password variables (masked in plan output)
- `TF_VAR_` environment variable pattern for secrets
- Multi-AZ vs Read Replica (HA vs read scaling — different purposes)
- RDS Proxy (connection pooling for serverless/containerised apps)
