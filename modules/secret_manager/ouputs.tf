output "secret_id" {
  description = "ID del secreto — para referenciarlo desde otros recursos"
  value       = google_secret_manager_secret.vcenter_password.id
}
