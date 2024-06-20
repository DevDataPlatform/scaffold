# This file is used to enable the services in the project.
# This should be implemented before creating any resources in the project.
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = var.gcp_project_name
  disable_services_on_destroy = false
  activate_apis = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",

  ]


}
