output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_migration_self_link" {
  value = google_compute_subnetwork.migration.self_link
}

output "subnet_management_self_link" {
  value = google_compute_subnetwork.management.self_link
}