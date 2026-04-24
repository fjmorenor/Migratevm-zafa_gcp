variable "org_id" {
  type = string
}

variable "tf_state_bucket" {
  type = string
}

variable "terraform_sa_email" {
  type = string
}

variable "apis_to_enable" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "vmmigration.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "iam.googleapis.com",
  ]
}

variable "vcenter_ip" {
  type = string
}

variable "vcenter_username" {
  type      = string
  sensitive = true
}

variable "vcenter_password" {
  type      = string
  sensitive = true
}

variable "vcenter_thumbprint" {
  type = string
}

variable "vms_to_migrate" {
  type = map(object({
    esxi_vm_id   = string # ID de la VM en ESXi
    target_name  = string # nombre que tendrá en GCP
    target_zone  = string # zona GCP donde arrancará
    machine_type = string # tipo de máquina GCP

  }))
  default = {}
}

variable "region" {
    type = string
}