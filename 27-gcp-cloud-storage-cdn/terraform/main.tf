terraform {
  required_version = ">= 1.3.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 5.0" } }
}
provider "google" { project = var.project_id; region = var.region }

# ── GCS Bucket (website origin) ──────────────────────────────────────────────
resource "google_storage_bucket" "website" {
  name          = "${var.project_id}-website"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

# ── Public read access ────────────────────────────────────────────────────────
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ── Upload website files ──────────────────────────────────────────────────────
resource "google_storage_bucket_object" "index" {
  name         = "index.html"
  bucket       = google_storage_bucket.website.name
  source       = "${path.module}/../source-code/index.html"
  content_type = "text/html"
  cache_control = "public, max-age=3600"
}

resource "google_storage_bucket_object" "style" {
  name         = "style.css"
  bucket       = google_storage_bucket.website.name
  source       = "${path.module}/../source-code/style.css"
  content_type = "text/css"
  cache_control = "public, max-age=86400"
}

# ── Load Balancer + Cloud CDN ─────────────────────────────────────────────────
resource "google_compute_backend_bucket" "website" {
  name        = "${var.project_id}-website-backend"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

resource "google_compute_url_map" "website" {
  name            = "${var.project_id}-website-urlmap"
  default_service = google_compute_backend_bucket.website.id
}

resource "google_compute_target_http_proxy" "website" {
  name    = "${var.project_id}-website-http-proxy"
  url_map = google_compute_url_map.website.id
}

resource "google_compute_global_address" "website" {
  name = "${var.project_id}-website-ip"
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.project_id}-website-http"
  target     = google_compute_target_http_proxy.website.id
  port_range = "80"
  ip_address = google_compute_global_address.website.address
}
