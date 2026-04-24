resource "google_storage_bucket" "state" {
    project = var.project_id
    name = var.bucket_name
    location = var.region
    uniform_bucket_level_access = true

    versioning {
    enabled = true
    }

    encryption {
      default_kms_key_name = var.kms_key_id
    }

    force_destroy = false
    
}

resource "google_storage_bucket_iam_member" "sa_access" {
    bucket = google_storage_bucket.state.name
    role   = "roles/storage.objectAdmin" # También asegúrate de la A mayúscula aquí por consistencia
    member = "serviceAccount:${var.terraform_sa_email}" # <--- Cambiado 'serviceaccount' por 'serviceAccount'
}