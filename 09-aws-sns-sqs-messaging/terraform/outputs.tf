output "sns_topic_arn" {
  value = aws_sns_topic.order_events.arn
}
output "orders_queue_url" {
  value = aws_sqs_queue.orders.url
}
output "notifications_queue_url" {
  value = aws_sqs_queue.notifications.url
}
output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}
