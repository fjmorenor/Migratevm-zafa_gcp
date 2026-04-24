# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURACIÓN DE TERRAFORM Y PROVEEDORES
# Esta sección define los requisitos técnicos del motor de Terraform y las 
# librerías externas (providers) necesarias para interactuar con Google Cloud.
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">=1.5.0"              # Exige que la versión de Terraform sea al menos la 1.5.0 para asegurar compatibilidad.

  required_providers {                      # Bloque donde se especifican los plugins necesarios.
    google = { 
      source  = "hashicorp/google"          # Fuente oficial del proveedor de Google Cloud en el registro de HashiCorp.
      version = "~> 5.0"                    # Permite versiones 5.x, evitando saltos a la 6.0 que podrían romper el código.
    }
    random = { 
      source  = "hashicorp/random"          # Proveedor para generar IDs, nombres o sufijos aleatorios.
      version = "~> 3.5"                    # Asegura una versión estable del generador de recursos aleatorios.
    }
  }

  # ─────────────────────────────────────────────────────────────────────────────
  # BACKEND DE ESTADO (GCS)
  # Define dónde se guarda el archivo .tfstate para permitir el trabajo colaborativo.
  # NOTA: Mantener comentado en el primer 'terraform apply'. Tras crear el bucket,
  # descomentar, actualizar el nombre del bucket y ejecutar 'terraform init'.
  # ─────────────────────────────────────────────────────────────────────────────

  backend "gcs" {                          # Indica que el estado se guardará en Google Cloud Storage.
   bucket  = "lz-tf-state-3effc8e5"       # Nombre del bucket creado previamente (debe coincidir con el ID generado).
    prefix  = "host/state"                 # Carpeta/Ruta dentro del bucket para organizar este estado específico.
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURACIÓN DEL PROVEEDOR GOOGLE
# Define las credenciales por defecto y el comportamiento de las llamadas a la API.
# ─────────────────────────────────────────────────────────────────────────────

provider "google" {
  region  = var.region                      # Región por defecto donde se desplegarán los recursos (ej: europe-west1).
  project = "lz-host-3effc8e5"              # ID del proyecto principal donde se ejecutarán las acciones.

  # Forzamos a que TODAS las peticiones de API se carguen a este proyecto
  # Esto es crítico cuando se gestionan recursos que afectan a la organización o facturación.
  user_project_override = true              # Obliga a usar las cuotas y límites del proyecto indicado abajo, no del recurso.
  billing_project       = "lz-host-3effc8e5" # Proyecto al que Google Cloud pasará la "factura" por el uso de las APIs.
  
  # Añade una etiqueta automática a todos los recursos indicando que fueron creados por Terraform.
  # Útil para auditoría y para evitar que GCP intente inferir el proyecto erróneamente.
  add_terraform_attribution_label = true    # Inserta metadatos de Terraform en las llamadas a la API de Google.
}