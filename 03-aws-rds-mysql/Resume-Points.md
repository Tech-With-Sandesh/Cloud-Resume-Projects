# Resume Points — Project 03: AWS RDS MySQL

---

## Fresher

- Provisioned an Amazon RDS MySQL 8.0 instance using Terraform with encrypted storage (AWS KMS), automated 7-day backups, and private-only access via DB Subnet Group in private subnets.
- Configured a custom RDS Parameter Group with utf8mb4 character set and slow query logging (`long_query_time = 2s`) for performance monitoring.
- Exported RDS logs (audit, error, general, slowquery) to Amazon CloudWatch Logs for centralised monitoring and query performance analysis.
- Used `sensitive = true` Terraform variable and `TF_VAR_db_password` environment variable pattern to prevent database credentials from appearing in plan output or being committed to Git.

---

## Experienced Cloud Engineer

- Designed a production-ready RDS MySQL architecture: private DB Subnet Group across 2 AZs, Security Group restricting port 3306 to app subnet CIDR only (no public accessibility), KMS-encrypted storage, 7-day automated backups with point-in-time recovery, and Multi-AZ standby for automatic failover in 60–120 seconds.
- Implemented RDS Parameter Group with utf8mb4 (full Unicode + emoji support), slow query log enabled (`long_query_time = 2s`) — enabling DBA-level query performance auditing via CloudWatch Logs.
- Documented production credential management using AWS Secrets Manager (runtime secret fetch via SDK), RDS Read Replicas for read scaling, and RDS Proxy for connection pooling in Lambda/container environments.
- Configured automated maintenance window and minor version auto-upgrade, balancing zero-downtime patching with controlled maintenance scheduling.

---

## LinkedIn Project Description

Provisioned a production-grade Amazon RDS MySQL 8.0 database using Terraform — private DB Subnet Group across 2 AZs, KMS-encrypted storage, 7-day automated backups with PITR, CloudWatch Logs (audit/error/slowquery), custom Parameter Group (utf8mb4 + slow query log). Implemented Security Group restricting MySQL access to app subnet only. Documented Multi-AZ failover, Read Replicas, RDS Proxy (connection pooling), and Secrets Manager as production upgrade paths.

---

## GitHub Project Description

AWS RDS MySQL 8.0 (Terraform) — Private subnet, DB Subnet Group, KMS encryption, 7-day backups, Parameter Group (utf8mb4, slow query log), CloudWatch Logs export, sensitive variable pattern. Production: Multi-AZ, Read Replica, RDS Proxy, Secrets Manager.

---

## How to Explain in an Interview (30 Seconds)

"I provisioned an RDS MySQL instance using Terraform with several production requirements. It's deployed in private subnets with a Security Group that only allows port 3306 from the app subnet — no public access. Storage is encrypted with KMS, automated backups run nightly with 7-day retention for point-in-time recovery. I configured a custom Parameter Group with utf8mb4 and slow query logging so every query over 2 seconds gets captured in CloudWatch. For credentials, I used Terraform's sensitive variable type and TF_VAR environment variables so the password never appears in plan output or git history."

---

## Skills Demonstrated

- Amazon RDS (MySQL 8.0, instance classes, storage types)
- DB Subnet Group (multi-AZ subnet requirement)
- RDS Security Groups (port-level, subnet CIDR restriction)
- KMS Encryption at rest (`storage_encrypted = true`)
- Automated Backups (retention period, backup window, PITR)
- RDS Parameter Group (utf8mb4, slow_query_log, long_query_time)
- CloudWatch Logs (RDS log export — audit/error/general/slowquery)
- Terraform sensitive variables (`TF_VAR_` pattern)
- Multi-AZ deployment (HA — synchronous standby)
- RDS Read Replicas (read scaling)
- RDS Proxy (connection pooling for Lambda/containers)
- AWS Secrets Manager (production credential management)
