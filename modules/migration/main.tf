/*# modules/migration/main.tf
#
# Este módulo hace la migración de VMs desde ESXi a GCP.
#
# ¿Cómo funciona Migrate to VMs?
#   1. Terraform configura la conexión con tu vCenter (google_vmmigration_source)
#   2. El agente de GCP se instala en el vCenter y empieza a replicar las VMs
#   3. Las VMs se replican continuamente en segundo plano (sin apagar nada)
#   4. Cuando quieras, haces el "cutover": la VM se apaga en ESXi y arranca en GCP

# PASO A: configurar la conexión con el vCenter
resource "google_vmmigration_source" "vcenter" {
    provider = google-beta
    project =var.project_id
    location = var.region
    source_id = "mi-vcenter"


    vmware {
    username = var.vcenter_username
    password = var.vcenter_password
    vcenter_ip = var.vcenter_ip
    thumbprint = var.vcenter_thumbprint
}

}

# PASO B: definir cada VM que quieres migrar
# for_each crea un recurso por cada VM en el mapa var.vms_to_migrate
resource "google_vmmigration_migrating_vm" "default" {
  provider = google-beta
for_each = var.vms_to_migrate

  source = google_vmmigration_source.vcenter.name
  vm_id = each.key

  # ID de la VM en ESXi (lo ves en la consola de vCenter)
  source_vm_id = each.value.esxi_vm_id

  compute_engine_target_defaults{
    vm_name = each.value.target_name
    target_project = "projects/${var.project_id}"
    zone = each.value.target_zone
    machine_type = each.value.machine_type
  }

  # Conectar a la red del host project vía Shared VPC
  network_interfaces {
    network = var.vpc_self_link
    subnetwork = var.subnet_self_link
  }

  # Cifrar el disco con la clave KMS del host
  encryption {
    kms_key = var.disk_key_id
  }

}


*/