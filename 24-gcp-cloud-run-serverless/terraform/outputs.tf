output "service_url"      { value = google_cloud_run_v2_service.main.uri }
output "artifact_registry" { value = google_artifact_registry_repository.main.name }
