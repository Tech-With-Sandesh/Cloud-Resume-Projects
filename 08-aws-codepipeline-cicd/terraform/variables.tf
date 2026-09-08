variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "project_name" {
  type    = string
  default = "cloud-cicd"
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "github_repo" {
  description = "GitHub repository in format: owner/repo-name"
  type        = string
  default     = "your-username/your-repo"
}
variable "github_branch" {
  description = "Branch to trigger pipeline on"
  type        = string
  default     = "main"
}
variable "ecs_cluster_name" {
  description = "ECS cluster name to deploy to"
  type        = string
  default     = "ecs-fargate-app-cluster"
}
variable "ecs_service_name" {
  description = "ECS service name to deploy to"
  type        = string
  default     = "ecs-fargate-app-service"
}
