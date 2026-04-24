variable "project_id" {
    type = string
}

variable "bucket_name" {
    type = string
}

variable "region" {
    type = string
}

variable "kms_key_id" {
    type = string
}

variable "terraform_sa_email" {
    type = string
    default = ""
}