output "api_endpoint" {
  description = "Base URL for the REST API"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/users"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.api.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.users.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.users.arn
}
