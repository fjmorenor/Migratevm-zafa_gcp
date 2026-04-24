resource "google_kms_key_ring" "main" {
    project = var.project_id
    name = "laz-keyring"
    location = var.region
    
}

resource "google_kms_crypto_key" "state" {
    name = "state_key"
    key_ring = google_kms_key_ring.main.id

}

resource "google_kms_crypto_key" "disk" {
    name = "disk_key"
    key_ring = google_kms_key_ring.main.id
    
}

data "google_storage_project_service_account" "gcs_account" {
    project = var.project_id
}

# Darle permiso para usar la llave
# CORRECCIÓN: Elimina "cloud_" del nombre del recurso
# Darle permiso para usar la llave
resource "google_kms_crypto_key_iam_member" "storage_kms" {
  # Cambiado de 'google_cloud_kms_crypto_key.state_key' 
  # a 'google_kms_crypto_key.state' para que coincida con tu recurso de arriba
  crypto_key_id = google_kms_crypto_key.state.id 
  
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}