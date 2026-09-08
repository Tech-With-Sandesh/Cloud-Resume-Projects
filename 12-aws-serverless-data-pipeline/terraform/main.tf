# ──────────────────────────────────────────
# Provider
# ──────────────────────────────────────────
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    archive = { source = "hashicorp/archive", version = "~> 2.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# ──────────────────────────────────────────
# S3 Buckets
# ──────────────────────────────────────────
resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-raw-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "${var.project_name}-raw", Stage = "input" }
}

resource "aws_s3_bucket" "processed" {
  bucket = "${var.project_name}-processed-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "${var.project_name}-processed", Stage = "output" }
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "processed" {
  bucket = aws_s3_bucket.processed.id
  versioning_configuration { status = "Enabled" }
}

# Lifecycle policy — move processed files to Glacier after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "processed" {
  bucket = aws_s3_bucket.processed.id
  rule {
    id     = "archive-to-glacier"
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration { days = 365 }
  }
}

data "aws_caller_identity" "current" {}

# ──────────────────────────────────────────
# IAM Role for Lambda
# ──────────────────────────────────────────
resource "aws_iam_role" "pipeline_lambda" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "pipeline_lambda" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.pipeline_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["s3:GetObject"], Resource = "${aws_s3_bucket.raw.arn}/*" },
      { Effect = "Allow", Action = ["s3:PutObject"], Resource = "${aws_s3_bucket.processed.arn}/*" },
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" }
    ]
  })
}

# ──────────────────────────────────────────
# Lambda Function — Transform
# ──────────────────────────────────────────
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../source-code/transform_lambda.py"
  output_path = "${path.module}/transform_lambda.zip"
}

resource "aws_lambda_function" "transform" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "${var.project_name}-transform"
  role             = aws_iam_role.pipeline_lambda.arn
  handler          = "transform_lambda.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 60
  memory_size      = 512

  environment {
    variables = { OUTPUT_BUCKET = aws_s3_bucket.processed.bucket }
  }

  tags = { Name = "${var.project_name}-transform" }
}

# ──────────────────────────────────────────
# S3 → Lambda Trigger
# ──────────────────────────────────────────
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transform.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = aws_s3_bucket.raw.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.transform.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
    filter_suffix       = ".json"
    }
  depends_on = [aws_lambda_permission.s3_invoke]
}

# ──────────────────────────────────────────
# Athena for Querying Processed Data
# ──────────────────────────────────────────
resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.project_name}-athena-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "${var.project_name}-athena-results" }
}

resource "aws_athena_workgroup" "main" {
  name = "${var.project_name}-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/results/"
    }
  }

  tags = { Name = "${var.project_name}-workgroup" }
}
