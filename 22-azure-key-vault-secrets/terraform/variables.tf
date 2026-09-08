variable "location" { type = string; default = "eastus" }
variable "resource_group_name" { type = string; default = "keyvault-rg" }
variable "project_name" { type = string; default = "cloud-kv" }
variable "environment" { type = string; default = "prod" }
variable "db_password" { type = string; sensitive = true }
variable "api_key" { type = string; sensitive = true }
variable "allowed_ip" { type = string; description = "Your public IP for Key Vault network ACL" }
