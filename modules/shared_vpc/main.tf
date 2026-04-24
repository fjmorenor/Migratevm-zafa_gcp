resource "google_compute_shared_vpc_host_project" "host" {
    
    project = var.host_project_id    
}

resource "google_compute_shared_vpc_service_project" "service" {
  count           = var.enable_shared_vpc ? 1 : 0
  host_project    = var.host_project_id
  service_project = var.service_project_id

  depends_on = [google_compute_shared_vpc_host_project.host]
}
resource "google_project_iam_member" "network_user" {
    
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${var.terraform_sa_email}"

    
}