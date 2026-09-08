terraform {
  required_version = ">= 1.3.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 5.0" } }
}
provider "google" { project = var.project_id; region = var.region }

# ── Notification Channel (email) ──────────────────────────────────────────────
resource "google_monitoring_notification_channel" "email" {
  display_name = "Ops Email Alerts"
  type         = "email"

  labels = { email_address = var.alert_email }
}

# ── Alert Policy — VM CPU High ────────────────────────────────────────────────
resource "google_monitoring_alert_policy" "vm_cpu_high" {
  display_name = "VM CPU Utilization > 80%"
  combiner     = "OR"

  conditions {
    display_name = "CPU Utilization"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.80
      duration        = "300s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
  severity              = "WARNING"

  documentation {
    content   = "VM CPU utilization exceeded 80% for 5 minutes. Investigate or scale."
    mime_type = "text/markdown"
  }
}

# ── Alert Policy — Cloud Run Error Rate ──────────────────────────────────────
resource "google_monitoring_alert_policy" "cloud_run_errors" {
  display_name = "Cloud Run 5xx Error Rate > 1%"
  combiner     = "OR"

  conditions {
    display_name = "5xx Error Rate"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.01
      duration        = "120s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
  severity              = "ERROR"
}

# ── Log-Based Metric — Application Errors ────────────────────────────────────
resource "google_logging_metric" "app_error_count" {
  name        = "app_error_count"
  description = "Count of application ERROR log entries"
  filter      = "severity >= ERROR AND logName =~ \"projects/${var.project_id}/logs/.*\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    display_name = "Application Error Count"
  }
}

# ── Alert on Log-Based Metric ─────────────────────────────────────────────────
resource "google_monitoring_alert_policy" "app_errors" {
  display_name = "Application Error Count > 10/min"
  combiner     = "OR"

  conditions {
    display_name = "App Error Rate"
    condition_threshold {
      filter          = "metric.type = \"logging.googleapis.com/user/app_error_count\" AND resource.type = \"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 10
      duration        = "60s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
  severity              = "CRITICAL"
}

# ── Log Sink → GCS (audit log archival) ──────────────────────────────────────
resource "google_storage_bucket" "log_archive" {
  name          = "${var.project_id}-log-archive"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 90 }
    action    { type = "Delete" }
  }
}

resource "google_logging_project_sink" "gcs_sink" {
  name        = "gcs-audit-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.log_archive.name}"
  filter      = "protoPayload.@type = \"type.googleapis.com/google.cloud.audit.AuditLog\""

  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "log_sink_writer" {
  bucket = google_storage_bucket.log_archive.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.gcs_sink.writer_identity
}
