# Resume Points — Project 25: GCP Cloud SQL PostgreSQL

---

## Fresher

- Deployed a GCP Cloud SQL PostgreSQL 15 instance using Terraform with private IP only (no public IP), SSL required for all connections, and daily automated backups with PITR (point-in-time recovery).
- Configured VPC peering via Service Networking API for private Cloud SQL access — allocated a /16 reserved IP range and connected it to the VPC using `google_service_networking_connection`.
- Enabled Query Insights on Cloud SQL for slow query detection (log_min_duration_statement = 2000ms), query plan recording, and application tag tracking.
- Used Cloud SQL Auth Proxy for secure local connections to a private-IP-only Cloud SQL instance — proxy handles IAM authentication and TLS, no VPN or public IP needed.

---

## Experienced Cloud Engineer

- Provisioned a production Cloud SQL PostgreSQL with private IP via Service Networking VPC peering (no public endpoint), SSL enforcement (`require_ssl = true`), database flags (log_checkpoints, log_connections, slow query 2s threshold), Query Insights (query string, application tags, client address), and 7-day PITR backup retention.
- Implemented private Cloud SQL connectivity pattern: `google_compute_global_address` (reserved /16 VPC_PEERING range) + `google_service_networking_connection` (peering with servicenetworking.googleapis.com) → Cloud SQL gets a private IP in the reserved range, accessible only from the peered VPC.
- Documented REGIONAL availability type (synchronous replication to a standby in different zone — automatic failover), Cloud SQL IAM database authentication (replace password with Application Default Credentials), and read replicas for horizontal read scaling.

---

## LinkedIn Project Description

Deployed GCP Cloud SQL PostgreSQL 15 using Terraform — private IP only (VPC peering via Service Networking), SSL required, Query Insights (slow query 2s, query plans, application tags), 7-day PITR backup, database flags (log_checkpoints, log_connections). Cloud SQL Auth Proxy for secure connections. REGIONAL availability type for HA with automatic failover documented.

---

## How to Explain in an Interview (30 Seconds)

"I deployed a Cloud SQL PostgreSQL instance using Terraform with private IP only — no public internet access. The private IP works through VPC peering: I reserve a private IP range in the VPC, then create a service networking connection that peers the VPC with Google's managed services network. Cloud SQL gets an IP from that range, so only applications in my VPC can connect. I also enabled Query Insights which captures the top queries by CPU and latency, including which application tag and client IP triggered them — very useful for debugging performance issues."

---

## Skills Demonstrated

- GCP Cloud SQL PostgreSQL 15 (private IP, SSL required)
- Service Networking VPC Peering (private Cloud SQL access)
- google_compute_global_address (reserved VPC_PEERING range)
- google_service_networking_connection (servicenetworking.googleapis.com)
- Query Insights (slow query, query plans, application tags)
- Database flags (log_checkpoints, log_connections, log_min_duration)
- Automated backups with PITR (point-in-time recovery)
- Cloud SQL Auth Proxy (secure connection, no VPN needed)
- REGIONAL vs ZONAL (HA failover vs single-zone)
- Cloud SQL IAM authentication (ADC replaces passwords)
- Read replicas (horizontal read scaling)
