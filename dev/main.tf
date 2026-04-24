# ─────────────────────────────────────────────
# CONFIGURACIÓN DEL PROVEEDOR Y SEGURIDAD
# Se define qué identidad usará Terraform para ejecutar los cambios.
# ─────────────────────────────────────────────

provider "google" {
  # Permite que Terraform "actúe como" (impersonate) la Service Account especificada.
  # Es una práctica de seguridad recomendada para no usar claves JSON locales.
  impersonate_service_account = var.terraform_sa_email 
  region = var.region
}



provider "google-beta" {
  impersonate_service_account = var.terraform_sa_email
  region                      = var.region
}

# ─────────────────────────────────────────────
# ACCESO AL ESTADO REMOTO (HOST)
# Permite leer los outputs de la infraestructura base (VPC, KMS, etc.) 
# sin tener que volver a definirlos o pasarlos manualmente.
# ─────────────────────────────────────────────

data "terraform_remote_state" "host" {
  backend = "gcs"                      # El estado del proyecto 'host' está en Google Cloud Storage.
  config = {
    bucket = "lz-tf-state-3effc8e5"      # Nombre del bucket donde reside el estado del host.
    prefix = "host/state"              # Ruta exacta del fichero de estado dentro del bucket.
  }
}

# ─────────────────────────────────────────────
# VARIABLES LOCALES
# Mapea los valores leídos del estado remoto a nombres cortos para facilitar su uso.
# ─────────────────────────────────────────────

locals {
  host_project_id  = data.terraform_remote_state.host.outputs.host_project_id           # ID del proyecto host.
  billing_id       = data.terraform_remote_state.host.outputs.billing_account_id       # Cuenta de facturación heredada.
  vpc_self_link    = data.terraform_remote_state.host.outputs.vpc_self_link            # Enlace único a la red compartida.
  subnet_migration = data.terraform_remote_state.host.outputs.subnet_migration_self_link # Subred específica para migrar VMs.
  subnet_mgmt      = data.terraform_remote_state.host.outputs.subnet_management_self_link # Subred para gestión (Grafana, etc).
  disk_key_id      = data.terraform_remote_state.host.outputs.disk_key_id              # Clave KMS para cifrar discos.
  region           = data.terraform_remote_state.host.outputs.region                   # Región de despliegue.
}

# ─────────────────────────────────────────────
# PASO 1: CREAR PROYECTO DE SERVICIO (DEV)
# ─────────────────────────────────────────────

resource "random_id" "suffix" {
  byte_length = 4
}

module "project" {
  source = "../modules/project"

  project_id         = "lz-dev-${random_id.suffix.hex}"              # ID del nuevo proyecto de desarrollo.
  org_id             = var.org_id             # ID de la organización.
  billing_account_id = local.billing_id       # Usa la misma cuenta de facturación que el host.
}

# ─────────────────────────────────────────────
# PASO 2: ACTIVAR APIS EN EL PROYECTO DEV
# ─────────────────────────────────────────────

module "apis" {
  source     = "../modules/apis"
  project_id = module.project.project_id
  apis       = var.apis_to_enable
  
  depends_on = [module.project]               # No se pueden activar APIs si el proyecto no existe.
}

# ─────────────────────────────────────────────
# PASO 3: VINCULAR A LA SHARED VPC
# Conecta este proyecto 'dev' a la red del proyecto 'host'.
# ─────────────────────────────────────────────

module "shared_vpc" {
  source = "../modules/shared_vpc"

  host_project_id    = local.host_project_id     # El proyecto anfitrión de la red.
  service_project_id = module.project.project_id # El proyecto que consumirá la red.
  terraform_sa_email = var.terraform_sa_email    # Identidad con permisos para realizar el vínculo.
  
  depends_on         = [module.apis]             # Requiere que la API de Compute Engine esté activa.
}

# ─────────────────────────────────────────────
# PASO 4: MIGRACIÓN DE MÁQUINAS VIRTUALES
# Configura el motor de migración desde vCenter hacia GCP.
# ─────────────────────────────────────────────

/*module "migration" {
  source = "../modules/migration"
  
  project_id         = module.project.project_id
  region             = local.region
  vpc_self_link      = local.vpc_self_link       # Usa la red del host leída en 'locals'.
  subnet_self_link   = local.subnet_migration    # Subred de destino para la migración.
  disk_key_id        = local.disk_key_id         # Cifra los discos migrados con KMS.
  vcenter_ip         = var.vcenter_ip            # IP del vCenter origen.
  vcenter_username   = var.vcenter_username      # Usuario de vCenter.
  vcenter_password   = var.vcenter_password      # Password de vCenter.
  vcenter_thumbprint = var.vcenter_thumbprint    # Huella de seguridad del certificado vCenter.
  vms_to_migrate     = var.vms_to_migrate        # Lista de VMs a traer.

  depends_on = [module.shared_vpc]               # Requiere que el vínculo de red esté listo.
}
*/

# ─────────────────────────────────────────────
# PASO 5: MONITORIZACIÓN CON GRAFANA
# Despliega una instancia de Grafana en el proyecto dev.
# ─────────────────────────────────────────────

module "grafana" {
  source = "../modules/grafana"

  project_id         = module.project.project_id
  zone               = "${local.region}-b"      # Despliegue en una zona específica (b).
  subnet_self_link   = local.subnet_mgmt         # Usa la subred de gestión del host.
  disk_key_id        = local.disk_key_id         # Cifra el disco de Grafana.
  

  depends_on = [module.shared_vpc]               # Requiere acceso a la red compartida.
}