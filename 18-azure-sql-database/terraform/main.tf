terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ──────────────────────────────────────────
# Azure SQL Server
# ──────────────────────────────────────────
resource "azurerm_mssql_server" "main" {
  name                         = "${var.project_name}-sqlserver"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = var.aad_admin_login
    object_id      = var.aad_admin_object_id
  }

  tags = { Environment = var.environment }
}

# ──────────────────────────────────────────
# Azure SQL Database (General Purpose)
# ──────────────────────────────────────────
resource "azurerm_mssql_database" "main" {
  name         = "${var.project_name}-db"
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  sku_name     = var.sku_name
  zone_redundant = false

  short_term_retention_policy {
    retention_days           = 7
    backup_interval_in_hours = 12
  }

  threat_detection_policy {
    state                      = "Enabled"
    email_account_admins       = true
    retention_days             = 30
  }

  tags = { Environment = var.environment }
}

# ──────────────────────────────────────────
# Firewall Rules
# ──────────────────────────────────────────
# Allow Azure services (e.g., App Service, Functions)
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow your IP for development
resource "azurerm_mssql_firewall_rule" "allow_dev_ip" {
  name             = "AllowDevIP"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = var.dev_ip_address
  end_ip_address   = var.dev_ip_address
}

# ──────────────────────────────────────────
# Diagnostic Settings (audit logs)
# ──────────────────────────────────────────
resource "azurerm_storage_account" "audit" {
  name                     = "${replace(var.project_name, "-", "")}audit"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  server_id                               = azurerm_mssql_server.main.id
  storage_endpoint                        = azurerm_storage_account.audit.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.audit.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 90
}
