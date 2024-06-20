variable "gcp_project_name" {
  type = string
}

variable "project_tag" {
  type = string

  validation {
    condition     = var.project_tag != "<fill-project-tag>"
    error_message = "You must provide your project tag in tf_backend.auto.tfvars."
  }

  validation {
    condition     = can(regex("^[a-z]+(-[a-z]+)*$", var.project_tag))
    error_message = "Invalid project tag. Project tags must be all lowercase letters with non-consecutive hyphens, e.g. my-superset-project."
  }
}

variable "billing_code" {
  type = string

  validation {
    condition     = var.billing_code != "<Fill Billing Code>"
    error_message = "You must provide your billing code in tf_backend.auto.tfvars."
  }
}

variable "region" {
  type    = string
  default = "us-central1"
}
