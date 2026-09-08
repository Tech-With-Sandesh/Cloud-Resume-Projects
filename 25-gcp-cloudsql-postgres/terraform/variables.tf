variable "project_id"       { type = string; description = "GCP Project ID" }
variable "region"           { type = string; default = "us-central1" }
variable "project_name"     { type = string; default = "cloud-sql" }
variable "tier"             { type = string; default = "db-f1-micro" }
variable "availability_type" { type = string; default = "ZONAL" }  # REGIONAL for HA
variable "database_name"    { type = string; default = "appdb" }
variable "db_user"          { type = string; default = "appuser" }
variable "db_password"      { type = string; sensitive = true }
