# Resume Points — Project 18: Azure SQL Database

---

## Fresher

- Deployed an Azure SQL Server and Database using Terraform with Azure AD administrator configured, minimum TLS 1.2 enforced, and firewall rules allowing only Azure services and a specific developer IP.
- Enabled Threat Detection policy on the database — detects SQL injection, anomalous access patterns, and brute force attempts, sending email alerts to administrators.
- Configured extended auditing policy storing all SQL Server audit logs to Azure Blob Storage with 90-day retention for compliance and forensics.
- Used Azure AD authentication (`sqlcmd -G`) to connect without SQL passwords, eliminating credential management.

---

## Experienced Cloud Engineer

- Provisioned a production Azure SQL database: SQL Server v12 (TLS 1.2 min) → Serverless Database (GP_S_Gen5_2 — auto-pause/resume) with AAD admin, threat detection (SQL injection + anomaly detection), 90-day audit logs (Azure Storage), and 7-day PITR backup — all Terraform-managed.
- Configured Azure AD administrator on SQL Server enabling AAD-based authentication for both human users (sqlcmd -G) and managed identity-based app connections — eliminating static SQL passwords from connection strings.
- Applied SQL firewall `0.0.0.0/0.0.0.0` pattern to allow Azure services while blocking internet IPs — only Azure-internal traffic (App Service, Functions) and a whitelisted developer IP can reach the server.
- Documented Private Endpoint for SQL (VNet integration — no public endpoint), Geo-replication for DR, Elastic Pools for multi-database cost sharing, and Long-term backup retention (weekly/monthly/yearly) as production extensions.

---

## LinkedIn Project Description

Deployed Azure SQL Server + Database using Terraform — AAD administrator (no SQL passwords), TLS 1.2 minimum, Serverless SKU (GP_S_Gen5_2 auto-pause), threat detection (SQL injection/anomaly, email alerts), extended audit logs (Azure Storage, 90 days), 7-day PITR backup. Firewall: Azure services + dev IP only. AAD authentication with sqlcmd -G.

---

## How to Explain in an Interview (30 Seconds)

"I deployed an Azure SQL Database using Terraform with two security features worth highlighting. First, I configured Azure AD authentication — so instead of a SQL username and password, my applications use their managed identity to authenticate. No password in connection strings, no credential rotation. Second, I enabled threat detection which monitors for SQL injection patterns and anomalous query behaviour. If something suspicious happens — like a login from an unexpected location or a classic SQL injection pattern — it sends an email alert within minutes and logs it to the audit storage account."

---

## Skills Demonstrated

- Azure SQL Server (v12, TLS 1.2, AAD administrator)
- Azure SQL Database (SKU naming, Serverless auto-pause)
- Azure AD authentication (sqlcmd -G, managed identity)
- SQL Firewall Rules (Azure services pattern, IP allowlisting)
- Threat Detection (SQL injection, anomaly, email alerts)
- Extended Auditing Policy (Storage Account, 90-day retention)
- Point-in-Time Restore (automated backup, 7-day window)
- Short-term retention policy (backup interval)
- Terraform azurerm_mssql_server + azurerm_mssql_database
- Private Endpoint (VNet integration — production path)
- Geo-replication (disaster recovery — production path)
