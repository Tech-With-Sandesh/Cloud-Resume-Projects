output "vpc_name"           { value = google_compute_network.global.name }
output "vpc_id"             { value = google_compute_network.global.id }
output "us_subnet_cidr"     { value = google_compute_subnetwork.us_central.ip_cidr_range }
output "europe_subnet_cidr" { value = google_compute_subnetwork.europe_west.ip_cidr_range }
output "asia_subnet_cidr"   { value = google_compute_subnetwork.asia_southeast.ip_cidr_range }
