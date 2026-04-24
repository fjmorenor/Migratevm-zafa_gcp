# dev/terraform.tfvars
# Los dos primeros valores los obtienes de los outputs del proyecto host:
#   cd ../host
#   terraform output tf_state_bucket_name
#   terraform output terraform_sa_email
 
org_id             = "963463312153"
tf_state_bucket    = "lz-tf-state-XXXXXXXX"
terraform_sa_email = "sa-terraform@lz-host-3effc8e5.iam.gserviceaccount.com"
region = "europe-west1"
 
# Datos de tu servidor ESXi / vCenter
vcenter_ip         = "192.168.1.135"
vcenter_username   = "root@vsphere.local"
vcenter_password   = "An@Belen1980"
vcenter_thumbprint = "5f3e34d54bf6600191e08936415b6eae096a06a6ccdff6cc914033806af66deb"
 
# VMs que quieres migrar
# Puedes añadir tantas como quieras siguiendo el mismo formato
vms_to_migrate = {
  "mi-vm-web" = {
    esxi_vm_id   = "vm-101"
    target_name  = "web-01"
    target_zone  = "europe-west1-b"
    machine_type = "e2-standard-2"
  }
}
