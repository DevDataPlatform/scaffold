# frontend repository

resource "google_artifact_registry_repository" "frontend_repository" {


  location      = var.region
  repository_id = "frontend-repo"
  format        = "DOCKER"

  description = "My Frontend Artifact Registry for Docker Images"

  labels = {
    environment = "prod"
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

# Backend repository

resource "google_artifact_registry_repository" "backend_repository" {


  location      = var.region
  repository_id = "backend-repo"
  format        = "DOCKER"

  description = "My Backend Artifact Registry for Docker Images"

  labels = {
    environment = "prod"
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

# prefect repository
resource "google_artifact_registry_repository" "prefect_repository" {


  location      = var.region
  repository_id = "prefect-repo"
  format        = "DOCKER"

  description = "My Prefect Artifact Registry for Docker Images"

  labels = {
    environment = "prod"
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

data "google_project" "project" {}

# This resource block defines an IAM binding for the "frontend_binding" of a Google Artifact Registry repository.
# It grants the "roles/artifactregistry.reader" role to a specific service account.
# The service account is identified by its email address, which is constructed using the project number of the Google Cloud project.
# The IAM binding allows the service account to read artifacts from the specified repository.

resource "google_artifact_registry_repository_iam_binding" "frontend_binding" {

  # The location of the Google Artifact Registry repository.
  location = google_artifact_registry_repository.frontend_repository.location

  # The project ID of the Google Cloud project that contains the repository.
  project = google_artifact_registry_repository.frontend_repository.project

  # The name of the Google Artifact Registry repository.
  repository = google_artifact_registry_repository.frontend_repository.name

  # The role to be granted to the service account.
  role = "roles/artifactregistry.reader"

  # The list of members (service accounts, groups, etc.) to which the role is granted.
  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

# backend binding
# This resource block defines the IAM binding for Backend Google Artifact Registry repository.
# It grants the "roles/artifactregistry.reader" role to a service account, allowing it to read from the repository.

resource "google_artifact_registry_repository_iam_binding" "backend_binding" {

  # The location of the repository.
  location = google_artifact_registry_repository.backend_repository.location

  # The project ID where the repository is located.
  project = google_artifact_registry_repository.backend_repository.project

  # The name of the repository.
  repository = google_artifact_registry_repository.backend_repository.name

  # The role to be granted to the members.
  role = "roles/artifactregistry.reader"

  # The members to whom the role will be granted.
  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

# This resource block defines the IAM binding for the "prefect_binding" role in the Google Artifact Registry repository.
# It grants the "roles/artifactregistry.reader" role to the specified members.

resource "google_artifact_registry_repository_iam_binding" "prefect_binding" {
  location   = google_artifact_registry_repository.prefect_repository.location
  project    = google_artifact_registry_repository.prefect_repository.project
  repository = google_artifact_registry_repository.prefect_repository.name
  role       = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}
