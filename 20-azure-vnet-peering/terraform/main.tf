terraform {
  required_version = ">= 1.3.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.80" } }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ── VNet A (Hub — 10.1.0.0/16) ──────────────────────────────────────────────
resource "azurerm_virtual_network" "hub" {
  name                = "hub-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = { Role = "Hub", Environment = var.environment }
}

resource "azurerm_subnet" "hub_default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ── VNet B (Spoke 1 — App — 10.2.0.0/16) ───────────────────────────────────
resource "azurerm_virtual_network" "spoke1" {
  name                = "spoke1-app-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = { Role = "Spoke-App", Environment = var.environment }
}

resource "azurerm_subnet" "spoke1_app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.2.1.0/24"]
}

# ── VNet C (Spoke 2 — DB — 10.3.0.0/16) ────────────────────────────────────
resource "azurerm_virtual_network" "spoke2" {
  name                = "spoke2-db-vnet"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = { Role = "Spoke-DB", Environment = var.environment }
}

resource "azurerm_subnet" "spoke2_db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.3.1.0/24"]
}

# ── VNet Peering: Hub ↔ Spoke1 ──────────────────────────────────────────────
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "spoke1-to-hub"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

# ── VNet Peering: Hub ↔ Spoke2 ──────────────────────────────────────────────
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke2"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "spoke2-to-hub"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

# ── NSG — Spoke2 DB: only allow from Spoke1 app subnet ──────────────────────
resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowAppSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.2.1.0/24"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "1433"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.spoke2_db.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}
