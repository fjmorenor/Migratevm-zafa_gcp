# host/variables.tf
#
# Aquí defines las entradas del proyecto host.
# Los valores concretos van en terraform.tfvars (no en este fichero).

variable "org_id" {
  description = "ID de tu organización GCP"
  type        = string
}

variable "billing_account_id" {
  description = "ID de tu cuenta de facturación GCP"
  type        = string
}

variable "region" {
  description = "Región donde se crean los recursos"
  type        = string
  default     = "europe-west1"
}

variable "apis_to_enable" {
  description = "Lista de APIs a activar en el proyecto host"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "orgpolicy.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

