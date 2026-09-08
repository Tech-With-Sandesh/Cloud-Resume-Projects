output "topic_name"          { value = google_pubsub_topic.orders.name }
output "subscription_name"   { value = google_pubsub_subscription.orders_processor.name }
output "dlq_topic"           { value = google_pubsub_topic.orders_dlq.name }
output "output_bucket"       { value = google_storage_bucket.output.name }
