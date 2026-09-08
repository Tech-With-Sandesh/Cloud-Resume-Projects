output "dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
output "sns_alert_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
output "app_log_group" {
  value = aws_cloudwatch_log_group.app.name
}
