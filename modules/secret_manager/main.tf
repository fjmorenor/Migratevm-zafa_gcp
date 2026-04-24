# modules/secret_manager/main.tf
#
# Secret Manager guarda contraseñas de forma segura.
# Aquí creamos el "hueco" donde irá la contraseña del vCenter.
# La contraseña en sí la introduces manualmente (no con Terraform)
# para que nunca quede guardada en el estado de Terraform.

resource "google_secret_manager_secret" "vcenter_password" {
  project   = var.project_id
  secret_id = "vcenter-password"

  replication {
    auto {}
  }
}