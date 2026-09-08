terraform {
  required_version = ">= 1.3.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 5.0" } }
}
provider "google" { project = var.project_id; region = var.region }

# ── Pub/Sub Topic ─────────────────────────────────────────────────────────────
resource "google_pubsub_topic" "orders" {
  name = "order-events"

  message_retention_duration = "86400s"  # 1 day

  labels = { environment = var.environment }
}

# ── Pub/Sub Dead Letter Topic ─────────────────────────────────────────────────
resource "google_pubsub_topic" "orders_dlq" {
  name = "order-events-dlq"
}

# ── Pub/Sub Subscriptions ─────────────────────────────────────────────────────
resource "google_pubsub_subscription" "orders_processor" {
  name  = "order-events-sub"
  topic = google_pubsub_topic.orders.name

  ack_deadline_seconds       = 30
  message_retention_duration = "86400s"
  retain_acked_messages      = false

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.orders_dlq.id
    max_delivery_attempts = 5
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  labels = { environment = var.environment }
}

resource "google_pubsub_subscription" "orders_analytics" {
  name  = "order-events-analytics-sub"
  topic = google_pubsub_topic.orders.name

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s"  # 7 days for analytics replay
  retain_acked_messages      = true

  labels = { environment = var.environment }
}

# ── Cloud Storage for Dataflow staging ───────────────────────────────────────
resource "google_storage_bucket" "dataflow" {
  name          = "${var.project_id}-dataflow-staging"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 7 }
    action    { type = "Delete" }
  }
}

resource "google_storage_bucket" "output" {
  name          = "${var.project_id}-pipeline-output"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}
