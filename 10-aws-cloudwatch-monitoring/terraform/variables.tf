variable "aws_region" { type = string; default = "ap-south-1" }
variable "project_name" { type = string; default = "cloud-monitoring" }
variable "environment" { type = string; default = "prod" }
variable "alert_email" { type = string; description = "Email address for CloudWatch alarm notifications" }
variable "ec2_instance_id" { type = string; description = "EC2 instance ID to monitor"; default = "i-0example" }
variable "rds_identifier" { type = string; description = "RDS DB instance identifier"; default = "cloud-rds-mysql" }
