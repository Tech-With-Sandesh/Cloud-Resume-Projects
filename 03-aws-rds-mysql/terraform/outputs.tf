output "rds_endpoint" {
  description = "RDS MySQL endpoint (host:port)"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_hostname" {
  description = "RDS MySQL hostname only"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mysql.port
}

output "rds_db_name" {
  description = "Database name"
  value       = aws_db_instance.mysql.db_name
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.mysql.arn
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.mysql.identifier
}
