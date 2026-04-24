resource "google_project" "this" {
    project_id = var.project_id
    name = var.project_id
    org_id = var.org_id
    billing_account = var.billing_account_id
    auto_create_network = false
}

