variable "project_id"   { type = string; description = "GCP Project ID" }
variable "region"       { type = string; default = "us-central1" }
variable "project_name" { type = string; default = "cloud-run-app" }
variable "image_name"   { type = string; default = "webapp" }
variable "image_tag"    { type = string; default = "latest" }
