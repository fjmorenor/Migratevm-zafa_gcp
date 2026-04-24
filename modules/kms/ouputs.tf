output "state_key_id" {
  value = google_kms_crypto_key.state.id

}

output "disk_key_id" {
  value = google_kms_crypto_key.disk.id
}