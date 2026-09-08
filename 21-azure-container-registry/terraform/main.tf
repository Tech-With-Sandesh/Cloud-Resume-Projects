terraform {
  required_version = ">= 1.3.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" } }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_string" "suffix" {
  length  = 6; special = false; upper = false
}

resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project_name, "-", "")}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = false

  retention_policy {
    days    = 30
    enabled = true
  }

  trust_policy { enabled = false }

  tags = { Environment = var.environment }
}

# ── Container Instance (run image from ACR) ──────────────────────────────────
resource "azurerm_user_assigned_identity" "aci" {
  name                = "${var.project_name}-aci-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "aci_acr_pull" {
  principal_id         = azurerm_user_assigned_identity.aci.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.main.id
}

resource "azurerm_container_group" "main" {
  name                = "${var.project_name}-aci"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.project_name}-${random_string.suffix.result}"
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  image_registry_credential {
    server                    = azurerm_container_registry.main.login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.aci.id
  }

  container {
    name   = var.project_name
    image  = "${azurerm_container_registry.main.login_server}/${var.image_name}:${var.image_tag}"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 5000
      protocol = "TCP"
    }

    environment_variables = {
      APP_VERSION = var.image_tag
    }

    liveness_probe {
      http_get {
        path   = "/health"
        port   = 5000
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 30
    }
  }

  depends_on = [azurerm_role_assignment.aci_acr_pull]
  tags       = { Environment = var.environment }
}
