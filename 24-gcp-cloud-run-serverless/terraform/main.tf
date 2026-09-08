terraform {
  required_version = ">= 1.3.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 5.0" } }
}
provider "google" { project = var.project_id; region = var.region }

# ── Artifact Registry (private container registry) ───────────────────────────
resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = var.project_name
  format        = "DOCKER"
  description   = "Container images for ${var.project_name}"
}

# ── Service Account for Cloud Run ────────────────────────────────────────────
resource "google_service_account" "cloud_run" {
  account_id   = "${var.project_name}-sa"
  display_name = "Cloud Run Service Account for ${var.project_name}"
}

# ── Cloud Run Service ─────────────────────────────────────────────────────────
resource "google_cloud_run_v2_service" "main" {
  name     = var.project_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.project_name}/${var.image_name}:${var.image_tag}"

      ports { container_port = 8080 }

      resources {
        limits = { cpu = "1", memory = "512Mi" }
        cpu_idle = true  # scale-to-zero
      }

      env {
        name  = "CLOUD_RUN_REGION"
        value = var.region
      }

      startup_probe {
        http_get { path = "/health"; port = 8080 }
        initial_delay_seconds = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      liveness_probe {
        http_get { path = "/health"; port = 8080 }
        period_seconds    = 30
        failure_threshold = 3
      }
    }
  }
}

# ── Allow unauthenticated access (public API) ─────────────────────────────────
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
