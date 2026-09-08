variable "location" { type = string; default = "eastus" }
variable "resource_group_name" { type = string; default = "acr-rg" }
variable "project_name" { type = string; default = "cloud-acr" }
variable "environment" { type = string; default = "prod" }
variable "image_name" { type = string; default = "webapp" }
variable "image_tag" { type = string; default = "1.0.0" }
