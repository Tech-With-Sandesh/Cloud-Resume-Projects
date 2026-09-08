variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "project_name" {
  type    = string
  default = "ecs-fargate-app"
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "ecr_repo_name" {
  type    = string
  default = "ecs-fargate-app"
}
variable "vpc_id" {
  description = "VPC ID to deploy ECS into"
  type        = string
}
variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}
variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}
variable "task_cpu" {
  type    = number
  default = 256
}
variable "task_memory" {
  type    = number
  default = 512
}
variable "desired_count" {
  type    = number
  default = 2
}
variable "max_count" {
  type    = number
  default = 6
}
