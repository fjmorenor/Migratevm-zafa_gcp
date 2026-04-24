variable "host_project_id"    { type = string }
variable "service_project_id" { type = string}
variable "terraform_sa_email" { type = string}
variable "enable_shared_vpc" {
  type    = bool
  default = true
}