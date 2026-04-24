output "bucket_name" {
  value = google_storage_bucket.state.name
}

output "debug_sa_email" {
  value = var.terraform_sa_email
}


