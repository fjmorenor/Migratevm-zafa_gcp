terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
    google-beta = { source = "hashicorp/google-beta", version = "~> 5.0" }
  }

  # El backend de dev usa el MISMO bucket que host, pero distinto prefix.
  # terraform init -backend-config="bucket=lz-tf-state-XXXX" \
  #               -backend-config="prefix=dev/state"
backend "gcs" {
  bucket  = "lz-tf-state-3effc8e5"
  prefix  = "dev/state"
  
}
}
