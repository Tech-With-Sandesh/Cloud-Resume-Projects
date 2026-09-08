# Project 18 - Azure SQL Database with AAD Auth, Auditing and Threat Detection

## Problem Statement

Your application needs a managed SQL Server database with:
- Azure Active Directory authentication (no SQL passwords for apps)
- Automatic backups with point-in-time restore (7 days)
- Threat detection for suspicious activities (SQL injection, brute force)
- Audit logging stored in Azure Storage for compliance
- TLS 1.2 minimum for all connections

---

## Architecture

```
Application (App Service / Function)
  │ Azure AD Managed Identity auth (no passwords)
  ▼
Azure SQL Server (v12, TLS 1.2 min)
  │
  ├── Firewall: Allow Azure services + dev IP only
  ├── AAD Administrator configured
  │
  ▼
Azure SQL Database (General Purpose Serverless — GP_S_Gen5_2)
  ├── Short-term backup: 7 days, 12-hour intervals
  ├── Threat Detection: SQL injection, anomalous access
  │
  └── Audit Logs → Azure Storage Account (90-day retention)
```

---

## Project Structure

```
18-azure-sql-database/
└── terraform/
    ├── main.tf      ← SQL Server, Database, firewall rules, AAD admin, auditing, threat detection
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## Step 1 — Get Your Azure AD Object ID

```bash
az login
az ad signed-in-user show --query id --output tsv
```

Copy the Object ID — you need it for `aad_admin_object_id`.

---

## Step 2 — Get Your Public IP

```bash
curl ifconfig.me
```

---

## Step 3 — Set Variables and Deploy

```bash
export TF_VAR_admin_password="YourSecurePass123!"
export TF_VAR_aad_admin_object_id="your-object-id-here"
export TF_VAR_dev_ip_address="203.0.113.45"
export TF_VAR_aad_admin_login="your-email@domain.com"

cd terraform/
terraform init && terraform apply
```

---

## Step 4 — Connect Using Azure AD Auth

```bash
# Install sqlcmd
# macOS: brew install sqlcmd
# Ubuntu: https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility

SERVER=$(terraform output -raw sql_server_fqdn)
DB=$(terraform output -raw database_name)

# Connect with Azure AD auth (no password)
sqlcmd -S "$SERVER" -d "$DB" -G -Q "SELECT @@VERSION"
```

---

## Step 5 — Run SQL Operations

```sql
-- Create a table
CREATE TABLE Products (
  Id          INT IDENTITY(1,1) PRIMARY KEY,
  Name        NVARCHAR(100) NOT NULL,
  Price       DECIMAL(10,2) NOT NULL,
  CreatedAt   DATETIME2 DEFAULT GETUTCDATE()
);

-- Insert data
INSERT INTO Products (Name, Price) VALUES ('Widget A', 19.99);
INSERT INTO Products (Name, Price) VALUES ('Widget B', 39.99);

-- Query
SELECT * FROM Products ORDER BY CreatedAt DESC;
```

---

## Step 6 — Verify Threat Detection

```bash
# Threat detection alerts are sent to admin email
# Test by running suspicious query:
# sqlcmd -S $SERVER -Q "SELECT * FROM Products WHERE 1=1 OR '1'='1'"
# An alert email will arrive within minutes
```

---

## Verification Checklist

✅ SQL Server created (v12, TLS 1.2 minimum)

✅ Azure AD administrator configured

✅ Database created (GP_S_Gen5_2 — Serverless)

✅ Firewall: Azure services + your IP only

✅ sqlcmd connects with Azure AD auth (no password)

✅ Threat Detection enabled with email alerts

✅ Audit logging → Storage Account (90-day retention)

✅ Point-in-time restore enabled (7-day backup)

---

## Troubleshooting

**Cannot connect — `Login failed`:**
- Verify firewall rule includes your current IP
- For Azure AD auth, ensure you're logged in: `az login`

**Threat Detection not sending emails:**
- Check Threat Detection policy has email_account_admins = true
- Verify admin email is set on the SQL Server

---

## Cleanup

```bash
terraform destroy
```

---

## Key Learnings

- Azure SQL Server (v12, TLS minimum version, AAD administrator)
- Azure SQL Database SKU naming (GP_S_Gen5_2 = General Purpose Serverless Gen5 2 vCores)
- Azure AD authentication for SQL (no SQL password for app connections)
- SQL firewall rules (0.0.0.0 = allow Azure services pattern)
- Threat Detection policy (SQL injection, anomaly detection, email alerts)
- Extended Auditing Policy (Storage Account, 90-day retention)
- Short-term retention policy (backup interval, retention days)
- Point-in-time restore (automated, within retention window)
- sqlcmd `-G` flag (Azure AD auth)
- Serverless SQL (auto-pause, auto-resume — cost for dev/test workloads)
