terraform {
  required_version = ">= 1.3.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" } }
}
provider "azurerm" { features { key_vault { purge_soft_delete_on_destroy = false } } }

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ── Key Vault ────────────────────────────────────────────────────────────────
resource "azurerm_key_vault" "main" {
  name                        = "${var.project_name}-kv-${random_string.suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.allowed_ip]
  }

  tags = { Environment = var.environment }
}

resource "random_string" "suffix" {
  length = 6; special = false; upper = false
}

# ── RBAC: Admin gets Key Vault Administrator ─────────────────────────────────
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ── Secrets ──────────────────────────────────────────────────────────────────
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id
  content_type = "password"

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "third-party-api-key"
  value        = var.api_key
  key_vault_id = azurerm_key_vault.main.id
  content_type = "api-key"

  depends_on = [azurerm_role_assignment.kv_admin]
}

# ── User-Assigned Identity for App ───────────────────────────────────────────
resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.project_name}-app-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# ── App gets Key Vault Secrets User (read secrets only) ──────────────────────
resource "azurerm_role_assignment" "app_kv_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# ── Diagnostic Settings (audit all access) ───────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "kv_audit" {
  name               = "${var.project_name}-kv-audit"
  target_resource_id = azurerm_key_vault.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log { category = "AuditEvent" }
  metric { category = "AllMetrics"; enabled = true }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}
