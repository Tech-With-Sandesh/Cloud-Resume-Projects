variable "aws_region" {
  description = "Primary AWS region for S3 bucket"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "cloud-cdn"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for CloudFront origin"
  type        = string
  default     = "cloud-cdn-origin-2024"
}
