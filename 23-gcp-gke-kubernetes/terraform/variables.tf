variable "project_id"    { type = string; description = "GCP Project ID" }
variable "region"        { type = string; default = "us-central1" }
variable "zone"          { type = string; default = "us-central1-a" }
variable "cluster_name"  { type = string; default = "cloud-gke" }
variable "environment"   { type = string; default = "prod" }
variable "machine_type"  { type = string; default = "e2-medium" }
variable "node_count"    { type = number; default = 2 }
variable "node_min_count" { type = number; default = 1 }
variable "node_max_count" { type = number; default = 5 }
