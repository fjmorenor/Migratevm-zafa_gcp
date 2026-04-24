# ==============================================================================
# CONFIGURACIÓN DEL BACKEND Y RECURSOS ALEATORIOS
# ==============================================================================

# El backend de GCS se define en providers.tf. 
# Nota: Para la ejecución inicial, debe comentarse el bloque 'backend' en providers.tf.
# Una vez creado el bucket (Paso 5), se descontinúa el comentario y se ejecuta 'terraform init -migrate-state'.

resource "random_id" "suffix" {      # Genera un ID único para evitar colisiones de nombres globales en GCP.
  byte_length = 4                   # Define que el sufijo tendrá 4 bytes (8 caracteres hexadecimales).
}

# ─────────────────────────────────────────────
# PASO 1: CREACIÓN DEL PROYECTO GCP
# Se encarga de instanciar el contenedor principal donde vivirán todos los recursos.
# ─────────────────────────────────────────────
module "project" {
  source = "../modules/project"     # Ruta local al código del módulo que crea el proyecto.

  project_id         = "lz-host-${random_id.suffix.hex}" # ID del proyecto combinando un prefijo fijo y el sufijo aleatorio.
  org_id             = var.org_id                        # ID de la organización de GCP donde se creará el proyecto.
  billing_account_id = var.billing_account_id            # Cuenta de facturación que asumirá los costes del proyecto.
}

# ─────────────────────────────────────────────
# PASO 2: ACTIVACIÓN DE APIS
# Un proyecto nuevo viene "vacío". Este módulo habilita los servicios (Compute, IAM, etc.) necesarios.
# ─────────────────────────────────────────────
module "apis" {
  source = "../modules/apis"        # Ruta al módulo encargado de gestionar las Google Cloud APIs.

  project_id = module.project.project_id # Vincula este módulo al proyecto creado en el Paso 1.
  apis       = var.apis_to_enable        # Lista de APIs (pasada por variable) que se deben activar.

  depends_on = [module.project]          # No puede activar APIs si el proyecto no ha sido creado primero.
}

# ─────────────────────────────────────────────
# PASO 3: SERVICE ACCOUNT DE TERRAFORM
# Crea la identidad (Service Account) con permisos para que Terraform gestione la infraestructura.
# ─────────────────────────────────────────────
module "iam" {
  source = "../modules/iam"         # Ruta al módulo que configura identidades y permisos.

  project_id = module.project.project_id # Proyecto donde se creará la cuenta de servicio.
  org_id     = var.org_id                # Necesario para asignar permisos a nivel de organización si fuera necesario.

  depends_on = [module.apis]             # Requiere que la API de IAM esté activa antes de crear la cuenta.
}

# ─────────────────────────────────────────────
# PASO 4: CLAVES DE CIFRADO (KMS)
# Genera las claves para el cifrado gestionado por el cliente (CMEK).
# ─────────────────────────────────────────────
module "kms" {
  source = "../modules/kms"          # Ruta al módulo de Key Management Service.

  project_id = module.project.project_id  # Proyecto donde se alojarán los llaveros (keyrings).
  region     = var.region                 # Ubicación geográfica de las claves de cifrado.

  depends_on = [module.apis]              # Requiere la API de Cloud KMS activa.
}

# ─────────────────────────────────────────────
# PASO 5: BUCKET DE ESTADO REMOTO
# Crea el bucket de Google Cloud Storage donde se almacenará el archivo .tfstate.
# ─────────────────────────────────────────────
module "storage" {
  source = "../modules/storage"      # Ruta al módulo de gestión de buckets de almacenamiento.

  project_id         = module.project.project_id         # Proyecto propietario del bucket.
  bucket_name        = "lz-tf-state-${random_id.suffix.hex}" # Nombre globalmente único para el bucket de estado.
  region             = var.region                        # Región donde se almacenarán los datos físicamente.
  kms_key_id         = module.kms.state_key_id           # Usa la clave del Paso 4 para cifrar los archivos de estado.
  terraform_sa_email = module.iam.sa_email               # Otorga permisos de escritura/lectura a la cuenta de Terraform.

  depends_on = [module.kms]          # El bucket no puede cifrarse si la clave KMS no existe aún.
}

# ─────────────────────────────────────────────
# PASO 6: CONFIGURACIÓN DE SHARED VPC
# Designa este proyecto como "Host" para que otros proyectos puedan usar su red.
# ─────────────────────────────────────────────
module "shared_vpc" {
  source = "../modules/shared_vpc"   # Ruta al módulo que configura la red compartida (Shared VPC).

  service_project_id = module.project.project_id # En este caso, el propio proyecto actúa también como servicio inicial.
  terraform_sa_email = module.iam.sa_email       # Identidad con permisos para administrar la red compartida.
  host_project_id    = module.project.project_id # Define este proyecto como el "anfitrión" de la red.

  depends_on = [module.apis]         # Requiere las APIs de Compute Engine activas.
}

# ─────────────────────────────────────────────
# PASO 7: RED VIRTUAL (VPC)
# Define la topología de red: segmentos, rangos IP y salida a internet controlada.
# ─────────────────────────────────────────────
module "network" {
  source = "../modules/network"      # Ruta al módulo que crea VPC, Subnets y Cloud NAT.

  project_id = module.project.project_id # Proyecto donde se despliega la infraestructura de red.
  region     = var.region                 # Región para las subredes y gateways.

  depends_on = [module.apis]             # Requiere las APIs de red activas.
}

# ─────────────────────────────────────────────
# PASO 8: FIREWALL
# Establece las reglas de seguridad de entrada y salida para el tráfico de red.
# ─────────────────────────────────────────────
module "firewall" {
  source = "../modules/firewall"     # Ruta al módulo de reglas de cortafuegos.

  project_id = module.project.project_id # Proyecto donde se aplican las reglas.
  network_id = module.network.vpc_id     # Vincula las reglas a la red específica creada en el Paso 7.

  depends_on = [module.network]          # No se pueden aplicar reglas a una red que no existe.
}

# ─────────────────────────────────────────────
# PASO 9: POLÍTICAS DE ORGANIZACIÓN
# Aplica restricciones de seguridad a nivel de gobierno (ej. restringir IPs externas).
# ─────────────────────────────────────────────
module "org_policies" {
  source = "../modules/org_policies" # Ruta al módulo de restricciones de cumplimiento.

  org_id = var.org_id                # Identificador de la organización para aplicar las "Org Policies".

  depends_on = [module.apis]         # Algunas políticas dependen de que ciertas APIs estén registradas.
}

# ─────────────────────────────────────────────
# PASO 10: SECRET MANAGER
# Almacena de forma segura credenciales sensibles, como las de vCenter.
# ─────────────────────────────────────────────
module "secret_manager" {
  source = "../modules/secret_manager" # Ruta al módulo de gestión de secretos.

  region     = var.region                # Ubicación de replicación del secreto.
  project_id = module.project.project_id # Proyecto donde se guardan los secretos.
  kms_key_id = module.kms.disk_key_id    # Cifra los secretos en reposo usando KMS.

  depends_on = [module.apis, module.kms] # Requiere la API de Secret Manager y la clave KMS.
}

# ─────────────────────────────────────────────
# PASO 11: LOGGING (AUDITORÍA)
# Configura el export de logs hacia BigQuery para análisis y retención a largo plazo.
# ─────────────────────────────────────────────
module "logging" {
  source = "../modules/logging"      # Ruta al módulo de observabilidad y logs.

  project_id = module.project.project_id # Proyecto origen de los logs.
  region     = var.region                # Región del dataset de BigQuery receptor.

  depends_on = [module.apis]             # Requiere las APIs de Logging y BigQuery.
}

# ─────────────────────────────────────────────
# PASO 12: MONITORING
# Crea paneles y alertas para vigilar la salud de la infraestructura.
# ─────────────────────────────────────────────
module "monitoring" {
  source = "../modules/monitoring"   # Ruta al módulo de Cloud Monitoring.

  project_id = module.project.project_id # Proyecto donde se monitorizarán los recursos.

  depends_on = [module.apis]             # Requiere la API de Cloud Monitoring activa.
}