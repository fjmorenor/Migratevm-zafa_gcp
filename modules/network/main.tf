resource "google_compute_network" "vpc" {
    name = "lz-vpc"
    project = var.project_id
    auto_create_subnetworks = false
    
}

resource "google_compute_subnetwork" "workloads" {
  project       = var.project_id
  name          = "subnet-workloads"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}


resource "google_compute_subnetwork" "migration"{
   name = "subnet-migration"
   project = var.project_id
   ip_cidr_range ="10.0.1.0/24"
   region = var.region
   network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "management" {
   name = "subnet-management"
   project = var.project_id
   ip_cidr_range = "10.0.2.0/24"
   region= var.region
   network = google_compute_network.vpc.id
    
}

resource "google_compute_router" "router" {
    name = "lz-router"
    project = var.project_id
    region = var.region
    network = google_compute_network.vpc.id
    
}

resource "google_compute_router_nat" "nat" {
   name = "lz-nat"
   project = var.project_id
   router = google_compute_router.router.name
   region = var.region
   nat_ip_allocate_option = "AUTO_ONLY"
   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

