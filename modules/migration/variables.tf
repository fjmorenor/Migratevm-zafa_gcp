/*variable "project_id"         { type = string }
variable "region"             {type = string}
variable "vpc_self_link"      { type = string }
variable "subnet_self_link"   { type = string }
variable "disk_key_id"        { type = string }
variable "vcenter_ip"         { type = string }
variable "vcenter_username"   {type = string}
variable "vcenter_password"   { type = string }
variable "vcenter_thumbprint" { type = string }
 
variable "vms_to_migrate" {
  type = map(object({
    esxi_vm_id   = string
    target_name  = string
    target_zone  = string
    machine_type = string
  }))
  default = {}
}
*/