output "website_ip"  { value = google_compute_global_address.website.address }
output "website_url" { value = "http://${google_compute_global_address.website.address}" }
output "gcs_url"     { value = "https://storage.googleapis.com/${google_storage_bucket.website.name}/index.html" }
