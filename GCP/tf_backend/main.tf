
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.26.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_name
  region  = var.region

}

# creaye storage kms key. This is needed since the terraform state may have sensitive information
resource "google_kms_key_ring" "terraform_state" {
  name     = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  location = var.region
}

/**
 * Resource: google_kms_crypto_key.terraform_state
 * 
 * This resource represents a Google Cloud KMS Crypto Key used for Terraform state encryption.
 * 
 * Attributes:
 * - name: The name of the crypto key.
 * - key_ring: The ID of the key ring that contains the crypto key.
 * - rotation_period: The rotation period for the crypto key in seconds.
 * - lifecycle.prevent_destroy: Specifies whether the crypto key can be destroyed.
 */
resource "google_kms_crypto_key" "terraform_state" {
  name            = "tfstate-bucket"
  key_ring        = google_kms_key_ring.terraform_state.id
  rotation_period = "86400s" # 1 day

  lifecycle {
    prevent_destroy = false
  }
}

data "google_project" "project" {}

# This will use the default service account for the service to access the key
resource "google_project_iam_member" "default_member" {
  project = data.google_project.project.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

/**
 * Resource: google_storage_bucket.terraform_state
 * 
 * This resource block defines a Google Cloud Storage bucket for storing Terraform state files.
 * 
 * Attributes:
 * - name: The name of the bucket, generated using a random ID and the prefix "bucket-tfstate".
 * - location: The region where the bucket will be created, specified by the variable "var.region".
 * - project: The name of the Google Cloud project, specified by the variable "var.gcp_project_name".
 * - force_destroy: Whether to allow the bucket to be forcefully deleted, set to false.
 * - storage_class: The storage class of the bucket, set to "STANDARD".
 * - versioning: Enables versioning for the bucket.
 * - encryption: Configures encryption for the bucket using a default KMS key.
 * 
 * Dependencies:
 * - google_kms_crypto_key.terraform_state: The KMS key used for encrypting the bucket.
 */
resource "google_storage_bucket" "terraform_state" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  location      = var.region
  project       = var.gcp_project_name
  force_destroy = false
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }


  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state.id
  }
}
