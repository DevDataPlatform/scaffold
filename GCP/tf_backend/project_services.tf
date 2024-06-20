/*
  This module configures the services for a Google Cloud Platform (GCP) project.
  
  It uses the "terraform-google-modules/project-factory/google//modules/project_services" module, version "~> 14.5".
  
  Inputs:
  - project_id: The ID of the GCP project.
  - disable_services_on_destroy: Whether to disable services when the project is destroyed.
  - activate_apis: A list of APIs to activate for the project.
  
  Outputs: None
  
*/
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = var.gcp_project_name
  disable_services_on_destroy = false
  activate_apis = [
    "iam.googleapis.com",
    "cloudkms.googleapis.com",
    "storage.googleapis.com"
  ]
}
