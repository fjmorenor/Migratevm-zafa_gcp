# ESXi to GCP Migration

This is a simple proyect to move VMs from VMware ESXi to Google Cloud using Terraform.

## How to use
1. Put your configs in `dev/terraform.tfvars`.
2. Go to `dev` folder in your terminal.
3. Type `terraform init` and then `terraform apply`.

## Important things
* You need the ESXi IP and user/pass.
* Turn off the VM in VMware before start or it fails.
* Dont upload your service account JSON to Github!! Use the `.gitignore`.

I hope this help someone. Sorry for my bad english.
