resource "google_service_account" "terraform_sa" {
    project = var.project_id
    account_id = "sa-terraform"
    display_name = "Terraform Landing Zone SA"    
}

resource "google_organization_iam_member" "roles" {
    for_each = toset ([
    "roles/resourcemanager.projectCreator",
    "roles/billing.user",
    "roles/compute.xpnAdmin",
    "roles/orgpolicy.policyAdmin",
  ])

org_id = var.org_id
role = each.value
member = "serviceAccount:${google_service_account.terraform_sa.email}"
    
}

resource "google_project_iam_member" "owner" {
    project = var.project_id
    role = "roles/owner"
    member = "serviceAccount:${google_service_account.terraform_sa.email}"
    
}