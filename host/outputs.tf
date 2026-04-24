# host/outputs.tf
#
# Aquí defines QUÉ información comparte el proyecto host con el exterior.
# El proyecto dev leerá estos outputs a través de terraform_remote_state.
#
# Formato: output "nombre" { value = de_donde_viene }

output "host_project_id" {
  description = "ID del proyecto host — dev lo necesita para adjuntarse a la Shared VPC"
  value       = module.project.project_id
}

output "terraform_sa_email" {
  description = "Email de la Service Account — dev la usa para impersonarla"
  value       = module.iam.sa_email
}

output "tf_state_bucket_name" {
  description = "Nombre del bucket de estado — dev lo usa como su propio backend"
  value       = module.storage.bucket_name
}

output "disk_key_id" {
  description = "Clave KMS para cifrar discos — dev la usa para Grafana y las VMs migradas"
  value       = module.kms.disk_key_id
}

output "vpc_self_link" {
  description = "Enlace a la VPC — dev lo pasa a sus VMs para que usen esta red"
  value       = module.network.vpc_self_link
}

output "subnet_migration_self_link" {
  description = "Enlace a la subnet de migración — las VMs migradas arrancan aquí"
  value       = module.network.subnet_migration_self_link
}

output "subnet_management_self_link" {
  description = "Enlace a la subnet de gestión — Grafana arranca aquí"
  value       = module.network.subnet_management_self_link
}

output "billing_account_id" {
  description = "ID de facturación — dev lo necesita al crear su propio proyecto"
  value       = var.billing_account_id
}

output "region" {
  description = "Región por defecto"
  value       = var.region
}
