variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "serverless-api"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for users"
  type        = string
  default     = "users-table"
}
