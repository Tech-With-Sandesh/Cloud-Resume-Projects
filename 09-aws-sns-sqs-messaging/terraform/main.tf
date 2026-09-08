# ──────────────────────────────────────────
# Provider
# ──────────────────────────────────────────
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# ──────────────────────────────────────────
# Dead Letter Queue (DLQ)
# ──────────────────────────────────────────
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-dlq"
  message_retention_seconds = 1209600  # 14 days
  tags                      = { Name = "${var.project_name}-dlq", Environment = var.environment }
}

# ──────────────────────────────────────────
# SQS Queue — Order Processing
# ──────────────────────────────────────────
resource "aws_sqs_queue" "orders" {
  name                       = "${var.project_name}-orders"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400  # 1 day
  receive_wait_time_seconds  = 20     # Long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "${var.project_name}-orders", Environment = var.environment }
}

# SQS Queue — Notifications
resource "aws_sqs_queue" "notifications" {
  name                       = "${var.project_name}-notifications"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 3600  # 1 hour
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "${var.project_name}-notifications", Environment = var.environment }
}

# ──────────────────────────────────────────
# SNS Topic — Order Events
# ──────────────────────────────────────────
resource "aws_sns_topic" "order_events" {
  name = "${var.project_name}-order-events"
  tags = { Name = "${var.project_name}-order-events", Environment = var.environment }
}

# ──────────────────────────────────────────
# SQS Queue Policies (allow SNS to send)
# ──────────────────────────────────────────
resource "aws_sqs_queue_policy" "orders" {
  queue_url = aws_sqs_queue.orders.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.orders.arn
      Condition = { ArnEquals = { "aws:SourceArn" = aws_sns_topic.order_events.arn } }
    }]
  })
}

resource "aws_sqs_queue_policy" "notifications" {
  queue_url = aws_sqs_queue.notifications.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.notifications.arn
      Condition = { ArnEquals = { "aws:SourceArn" = aws_sns_topic.order_events.arn } }
    }]
  })
}

# ──────────────────────────────────────────
# SNS Subscriptions (Fan-out)
# ──────────────────────────────────────────
resource "aws_sns_topic_subscription" "orders" {
  topic_arn            = aws_sns_topic.order_events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.orders.arn
  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "notifications" {
  topic_arn            = aws_sns_topic.order_events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.notifications.arn
  raw_message_delivery = true
}

# ──────────────────────────────────────────
# Lambda Consumer — Order Processor
# ──────────────────────────────────────────
resource "aws_iam_role" "lambda_consumer" {
  name = "${var.project_name}-lambda-consumer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "lambda_consumer" {
  name = "${var.project_name}-lambda-consumer-policy"
  role = aws_iam_role.lambda_consumer.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"], Resource = aws_sqs_queue.orders.arn },
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" }
    ]
  })
}

data "archive_file" "consumer" {
  type        = "zip"
  output_path = "${path.module}/consumer.zip"
  source {
    content  = <<-EOF
      import json, logging
      logger = logging.getLogger()
      logger.setLevel(logging.INFO)

      def lambda_handler(event, context):
          for record in event['Records']:
              body = json.loads(record['body'])
              logger.info("Processing order: %s", json.dumps(body))
          return {'statusCode': 200, 'body': f'Processed {len(event["Records"])} orders'}
    EOF
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "order_consumer" {
  filename         = data.archive_file.consumer.output_path
  function_name    = "${var.project_name}-order-consumer"
  role             = aws_iam_role.lambda_consumer.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.consumer.output_base64sha256
  timeout          = 30

  tags = { Name = "${var.project_name}-order-consumer" }
}

# Lambda SQS trigger (event source mapping)
resource "aws_lambda_event_source_mapping" "orders" {
  event_source_arn = aws_sqs_queue.orders.arn
  function_name    = aws_lambda_function.order_consumer.arn
  batch_size       = 10
}
