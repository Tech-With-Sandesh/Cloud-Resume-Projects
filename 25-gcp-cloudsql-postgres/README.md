# Project 25 - GCP Cloud SQL PostgreSQL with Private IP, Query Insights and Automated Backups

## Problem Statement

Your application needs a managed PostgreSQL database with:
- Private IP only (no public internet access)
- SSL/TLS required for all connections
- Automated daily backups with point-in-time recovery
- Query performance insights (slow query detection)
- Audit logging (connections and checkpoints)

---

## Architecture

```
Application (GKE / Cloud Run — VPC)
  │ SSL/TLS required
  ▼ Private IP (no public IP)
Cloud SQL PostgreSQL 15
  ├── Private IP via VPC Peering (Service Networking)
  ├── Backup: daily at 03:00, 7-day retention, PITR enabled
  ├── Flags: log_checkpoints, log_connections, slow query > 2s
  ├── Query Insights: enabled (query plans, tags, client address)
  └── Availability: ZONAL (or REGIONAL for HA with failover replica)
```

---

## Project Structure

```
25-gcp-cloudsql-postgres/
└── terraform/
    ├── main.tf      ← Cloud SQL, VPC, private IP range, VPC peering, DB, user
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Enable APIs

```bash
gcloud services enable \
  sqladmin.googleapis.com \
  servicenetworking.googleapis.com \
  --project YOUR_PROJECT_ID
```

---

## Step 2 — Deploy

```bash
export TF_VAR_db_password="SecurePass123!"

cd terraform/
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

> ⚠️ Private IP Cloud SQL creation takes 5–10 minutes (VPC peering setup).

---

## Step 3 — Connect via Cloud SQL Auth Proxy

```bash
# Install Cloud SQL Auth Proxy
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

# Start proxy (maps to localhost:5432)
CONNECTION_NAME=$(terraform output -raw connection_name)
./cloud-sql-proxy "$CONNECTION_NAME" --port 5432 &

# Connect with psql
psql "host=127.0.0.1 port=5432 dbname=appdb user=appuser sslmode=require"
```

---

## Step 4 — Run SQL Operations

```sql
CREATE TABLE orders (
  id         SERIAL PRIMARY KEY,
  customer   VARCHAR(100) NOT NULL,
  amount     NUMERIC(10,2) NOT NULL,
  status     VARCHAR(20) DEFAULT 'placed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO orders (customer, amount) VALUES ('Alice', 99.99), ('Bob', 249.50);
SELECT * FROM orders ORDER BY created_at DESC;
```

---

## Step 5 — View Query Insights

1. Cloud Console → **Cloud SQL** → `cloud-sql-postgres` → **Query Insights**
2. See: top queries by CPU, latency, lock wait time
3. Filter by: tag, user, database, time range

---

## Verification Checklist

✅ Cloud SQL instance: `RUNNABLE` state

✅ Private IP only (no public IP)

✅ SSL required (require_ssl = true)

✅ VPC peering connected (service networking)

✅ Automated backup: enabled, 03:00 UTC, 7-day retention

✅ PITR: enabled

✅ Query Insights: enabled

✅ Cloud SQL Proxy connects and psql works

---

## Troubleshooting

**`VPC peering range conflict`:**
- Change `prefix_length = 16` range if it conflicts with existing VPC CIDRs
- Use `gcloud compute networks peerings list` to check existing peerings

**Connection refused via proxy:**
- Verify Cloud SQL Auth Proxy is running and connected
- Check IAM: your account needs `roles/cloudsql.client`

---

## Cleanup

```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

---

## Key Learnings

- Cloud SQL PostgreSQL 15 (private IP, SSL required)
- Service Networking (VPC peering for private Cloud SQL access)
- `google_compute_global_address` (reserved private IP range for peering)
- `availability_type = REGIONAL` vs `ZONAL` (HA with automatic failover)
- Cloud SQL Auth Proxy (secure connection without public IP)
- Database flags (log_checkpoints, log_connections, log_min_duration)
- Query Insights (top queries, latency, lock analysis)
- Point-in-time recovery (PITR) — restore to any second within backup window
- `deletion_protection = false` (allow terraform destroy for dev)
- Cloud SQL IAM database authentication (ADC instead of password)
