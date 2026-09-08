# Project 22 - Azure Key Vault: Secrets Management with RBAC, Network ACL and Audit Logging

## Problem Statement

Your application needs centralized secret management with:
- No secrets in code, environment variables, or config files
- Applications access secrets using Managed Identity (no passwords)
- Network-level restriction (Key Vault accessible only from specific IPs)
- Soft delete + purge protection (secrets cannot be permanently deleted)
- All access attempts logged for compliance (90-day audit retention)

---

## Architecture

```
Developer (allowed_ip)  ←→  Key Vault (network ACL: DenyAll + IP allowlist)
                                  │
Application (Managed Identity)    │  Key Vault Secrets User role (read-only)
  └── SDK: get_secret("db-password") → decrypted value at runtime
                                  │
Admin (current user)              │  Key Vault Administrator role (full access)
                                  │
                           Audit Logs → Log Analytics (90 days)
                           Soft Delete: 7 days
                           Purge Protection: Enabled
```

---

## Project Structure

```
22-azure-key-vault-secrets/
└── terraform/
    ├── main.tf    ← Key Vault, RBAC roles, secrets, identity, audit logs
    ├── variables.tf
    └── outputs.tf
```

---

## Step 1 — Deploy

```bash
export TF_VAR_db_password="YourSecureDBPassword123!"
export TF_VAR_api_key="sk-your-third-party-api-key"
export TF_VAR_allowed_ip="$(curl -s ifconfig.me)"

az group create --name keyvault-rg --location eastus
cd terraform/
terraform init && terraform apply
```

---

## Step 2 — Read Secret via Azure CLI

```bash
KV_NAME=$(terraform output -raw key_vault_name)

az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "db-password" \
  --query "value" \
  --output tsv
```

---

## Step 3 — Read Secret via Python SDK (App Pattern)

```python
from azure.identity import DefaultAzureCredential, ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

# In production, use ManagedIdentityCredential with client_id
client_id = "YOUR_APP_IDENTITY_CLIENT_ID"  # From terraform output
credential = ManagedIdentityCredential(client_id=client_id)

kv_uri = "https://cloud-kv-abc123.vault.azure.net/"
client = SecretClient(vault_url=kv_uri, credential=credential)

db_password = client.get_secret("db-password").value
print(f"DB Password retrieved: {db_password[:3]}...")  # Never log the full secret
```

---

## Step 4 — View Audit Logs (KQL)

```kql
-- Run in Log Analytics → Logs tab
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName == "SecretGet"
| project TimeGenerated, CallerIPAddress, ResultType, identity_claim_oid_g
| order by TimeGenerated desc
| take 100
```

---

## Verification Checklist

✅ Key Vault created (RBAC mode, soft delete 7 days, purge protection ON)

✅ Network ACL: default=Deny, allowed_ip in ip_rules

✅ Both secrets created (db-password, third-party-api-key)

✅ Current user has Key Vault Administrator role

✅ App identity has Key Vault Secrets User role (read-only)

✅ `az keyvault secret show` returns secret value

✅ Audit logs flowing to Log Analytics (check after 5 min)

---

## Troubleshooting

**`Forbidden` when reading secrets:**
- Verify your IP is in the network ACL (`az keyvault show --name $KV --query properties.networkAcls`)
- Check RBAC role assignment: you need `Key Vault Secrets User` or `Key Vault Administrator`

**`Secret not found` from application:**
- Verify app managed identity has `Key Vault Secrets User` role on the Key Vault
- Check managed identity client_id matches what's used in SDK

---

## Cleanup

```bash
cd terraform/
terraform destroy
# Note: purge_protection_enabled=true means Key Vault enters soft-delete.
# Purge manually after 7 days if needed:
# az keyvault purge --name <kv-name>
```

---

## Key Learnings

- Azure Key Vault RBAC mode (vs legacy Access Policies)
- Key Vault Secrets User vs Key Vault Administrator (least-privilege)
- Network ACL (default_action=Deny, ip_rules allowlist, AzureServices bypass)
- Soft delete + purge protection (protection against accidental/malicious deletion)
- `purge_soft_delete_on_destroy = false` in Terraform (prevents destroy of protected vault)
- User-Assigned Managed Identity for applications (no credentials in code)
- Python azure-keyvault-secrets SDK (ManagedIdentityCredential at runtime)
- Diagnostic settings → Log Analytics (AuditEvent logs, 90-day retention)
- KQL query for Key Vault audit events (SecretGet, who accessed what)
- Secret content_type (documenting what kind of value it is)
