variable "location" { type = string; default = "eastus" }
variable "resource_group_name" { type = string; default = "sql-rg" }
variable "project_name" { type = string; default = "cloud-sql" }
variable "environment" { type = string; default = "prod" }
variable "admin_username" { type = string; default = "sqladmin" }
variable "admin_password" { type = string; sensitive = true }
variable "aad_admin_login" { type = string; description = "Azure AD admin login name"; default = "your-aad-user@domain.com" }
variable "aad_admin_object_id" { type = string; description = "Azure AD admin object ID" }
variable "sku_name" { type = string; default = "GP_S_Gen5_2" }  # General Purpose Serverless
variable "dev_ip_address" { type = string; description = "Your public IP for firewall rule" }
