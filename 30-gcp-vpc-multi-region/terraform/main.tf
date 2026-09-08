terraform {
  required_version = ">= 1.3.0"
  required_providers { google = { source = "hashicorp/google", version = "~> 5.0" } }
}
provider "google" { project = var.project_id }

# ── Global VPC ────────────────────────────────────────────────────────────────
resource "google_compute_network" "global" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# ── US Central Subnet ─────────────────────────────────────────────────────────
resource "google_compute_subnetwork" "us_central" {
  name          = "${var.project_name}-us-central"
  ip_cidr_range = "10.1.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.global.id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── Europe West Subnet ────────────────────────────────────────────────────────
resource "google_compute_subnetwork" "europe_west" {
  name          = "${var.project_name}-europe-west"
  ip_cidr_range = "10.2.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.global.id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── Asia Southeast Subnet ─────────────────────────────────────────────────────
resource "google_compute_subnetwork" "asia_southeast" {
  name          = "${var.project_name}-asia-southeast"
  ip_cidr_range = "10.3.0.0/24"
  region        = "asia-southeast1"
  network       = google_compute_network.global.id
}

# ── Firewall Rules ────────────────────────────────────────────────────────────
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.global.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow { protocol = "icmp" }

  source_ranges = ["10.0.0.0/8"]
  description   = "Allow all internal traffic between regions"
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.project_name}-allow-http-https"
  network = google_compute_network.global.name

  allow { protocol = "tcp"; ports = ["80", "443"] }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  description   = "Allow HTTP/HTTPS from internet to web servers"
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${var.project_name}-allow-ssh-iap"
  network = google_compute_network.global.name

  allow { protocol = "tcp"; ports = ["22"] }

  source_ranges = ["35.235.240.0/20"]  # IAP CIDR
  description   = "Allow SSH via Identity-Aware Proxy (no public SSH)"
}

# ── Global Cloud Router (for Cloud NAT) ───────────────────────────────────────
resource "google_compute_router" "us_central" {
  name    = "${var.project_name}-router-us"
  region  = "us-central1"
  network = google_compute_network.global.id
}

resource "google_compute_router_nat" "us_central" {
  name                               = "${var.project_name}-nat-us"
  router                             = google_compute_router.us_central.name
  region                             = google_compute_router.us_central.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "europe_west" {
  name    = "${var.project_name}-router-eu"
  region  = "europe-west1"
  network = google_compute_network.global.id
}

resource "google_compute_router_nat" "europe_west" {
  name                               = "${var.project_name}-nat-eu"
  router                             = google_compute_router.europe_west.name
  region                             = google_compute_router.europe_west.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
