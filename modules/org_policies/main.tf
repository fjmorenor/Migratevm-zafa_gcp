resource "google_org_policy_policy" "name" {
    name = "organizations/${var.org_id}/policies/compute.requireOsLogin"
    parent = "organizations/${var.org_id}"
    spec {
      rules {
        enforce = "TRUE"
      }
    }
    
}

resource "google_org_policy_policy" "no_default_network" {
    name = "organizations/${var.org_id}/policies/compute.skipDefaultNetworkCreation"
    parent = "organizations/${var.org_id}"
    spec { 
        rules { enforce = "TRUE" } 
        }
}


resource "google_org_policy_policy" "europe_only" {
  name   = "organizations/${var.org_id}/policies/gcp.resourceLocations"
  parent = "organizations/${var.org_id}"
  spec {
    rules {
      values { allowed_values = ["in:europe-locations"] }
    }
  }
}
