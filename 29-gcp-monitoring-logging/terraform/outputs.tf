output "notification_channel" { value = google_monitoring_notification_channel.email.name }
output "log_archive_bucket"   { value = google_storage_bucket.log_archive.name }
output "log_based_metric"     { value = google_logging_metric.app_error_count.name }
