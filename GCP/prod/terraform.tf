terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.26.0"
    }
  }

  backend "gcs" {
    bucket = "6046592a148f0d30-bucket-tfstate"
    prefix = "prod/"
  }

}

provider "google" {
  project = var.gcp_project_name
  region  = "us-central1"
}

provider "google-beta" {
  project = var.gcp_project_name
  region  = "us-central1"
}

