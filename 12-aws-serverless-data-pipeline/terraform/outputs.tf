output "raw_bucket" { value = aws_s3_bucket.raw.bucket }
output "processed_bucket" { value = aws_s3_bucket.processed.bucket }
output "lambda_function" { value = aws_lambda_function.transform.function_name }
output "athena_workgroup" { value = aws_athena_workgroup.main.name }
