# Resume Points — Project 22: Azure Key Vault Secrets Management

---

## Fresher

- Deployed an Azure Key Vault with RBAC authorisation mode, network ACL (default=Deny, IP allowlist), soft delete (7 days), and purge protection enabled using Terraform.
- Configured least-privilege RBAC: admin user gets Key Vault Administrator role, application managed identity gets Key Vault Secrets User role (read-only, cannot create/delete secrets).
- Stored database password and API key as Key Vault secrets with `content_type` metadata for documentation; used Terraform `sensitive = true` for secret variables (masked in plan output).
- Enabled Key Vault Diagnostic Settings sending AuditEvent logs to Log Analytics Workspace with 90-day retention for compliance and forensics.

---

## Experienced Cloud Engineer

- Architected Azure Key Vault in RBAC mode (replacing legacy Access Policies): Key Vault Administrator (full control) for admin, Key Vault Secrets User (get/list secrets only) for application managed identity — scoped to Key Vault resource ID, not subscription.
- Implemented defence-in-depth Key Vault security: Network ACL (default=Deny + AzureServices bypass + IP allowlist), purge protection (prevents accidental/malicious permanent deletion), soft delete 7-day recovery window, RBAC (no Access Policy legacy mode).
- Application secret retrieval pattern: ManagedIdentityCredential (client_id specified for user-assigned) → SecretClient → `get_secret()` at runtime — zero static credentials, automatic token refresh, no secrets in environment variables or config files.
- Documented Key Vault Private Endpoint (VNet integration — no public endpoint), Customer-Managed Keys (CMK) for encryption at rest, and Key Vault certificate management as production extensions.

---

## LinkedIn Project Description

Deployed Azure Key Vault (RBAC mode, purge protection, soft delete 7d, network ACL default=Deny+IP allowlist) using Terraform. RBAC: Key Vault Administrator for admin, Key Vault Secrets User (read-only) for app managed identity. AuditEvent diagnostic logs → Log Analytics (90-day retention). KQL queries for secret access audit. Python SDK pattern: ManagedIdentityCredential → SecretClient → get_secret() at runtime.

---

## How to Explain in an Interview (30 Seconds)

"I set up Azure Key Vault for centralized secret management. The important design decisions are: first, I use RBAC mode instead of legacy Access Policies — it's more granular and consistent with Azure's RBAC system. Second, I have separate roles — my admin has Key Vault Administrator, but the application's managed identity only has Key Vault Secrets User, which means it can only read secrets, not create or delete them. Third, I enabled purge protection so even if someone deletes the Key Vault, it goes into soft delete and can't be permanently purged for 7 days — protecting against both accidents and ransomware. All access is logged to Log Analytics so we have a full audit trail."

---

## Skills Demonstrated

- Azure Key Vault (RBAC mode, standard SKU, soft delete, purge protection)
- Key Vault RBAC roles (Administrator vs Secrets User — least privilege)
- Network ACL (default=Deny, AzureServices bypass, IP allowlist)
- User-Assigned Managed Identity (application authentication)
- Python azure-keyvault-secrets SDK (ManagedIdentityCredential)
- Diagnostic Settings (AuditEvent logs → Log Analytics)
- KQL (Kusto Query Language for audit event queries)
- Soft delete + purge protection (accidental deletion safeguard)
- Terraform sensitive variables (TF_VAR_ pattern, masked output)
- Key Vault Private Endpoint (production VNet integration)
- Customer-Managed Keys (CMK) for encryption at rest
