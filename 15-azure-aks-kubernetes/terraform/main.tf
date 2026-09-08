# ──────────────────────────────────────────
# Provider
# ──────────────────────────────────────────
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" }
  }
}

provider "azurerm" {
  features {}
}

# ──────────────────────────────────────────
# Resource Group
# ──────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = { Environment = var.environment, Project = var.project_name }
}

# ──────────────────────────────────────────
# Azure Container Registry
# ──────────────────────────────────────────
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project_name, "-", "")}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = { Environment = var.environment }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ──────────────────────────────────────────
# AKS Cluster
# ──────────────────────────────────────────
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project_name}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.project_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.node_min_count
    max_count           = var.node_max_count
    zones               = ["1", "2"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  tags = { Environment = var.environment, Project = var.project_name }
}

# ──────────────────────────────────────────
# Log Analytics Workspace (Container Insights)
# ──────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = { Environment = var.environment }
}

# ──────────────────────────────────────────
# AKS → ACR Integration (pull images without credentials)
# ──────────────────────────────────────────
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}
