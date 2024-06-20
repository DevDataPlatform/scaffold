# This Terraform resource block defines a Google Cloud SQL database instance for a Postgres database.
# It creates a Postgres database instance with the specified name, database version, and region.

resource "google_sql_database_instance" "postgres" {
  name             = var.db_instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  # Configuration settings for the Postgres database instance.
  settings {
    tier      = var.db_instance_type
    disk_size = 50
    disk_type = "PD_HDD"

    # Fixing the issue of "FATAL: remaining connection slots are reserved for non-replication superuser connections"
    database_flags {
      name  = "max_connections"
      value = "100"
    }

    # IP configuration for the database instance.
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc
    }
  }
}

# default user
# Added this so as to set password for the default user
resource "google_sql_user" "postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password[0].result
}

# This is the main dalgo database
resource "google_sql_database" "dalgo_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "dalgo_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password[1].result
}

# this is the prefect metadata database
resource "google_sql_database" "prefect_db" {
  name     = var.prefect_db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "prefect_user" {
  name     = var.prefect_db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password[2].result
}

# This is the airbyte metadata database
resource "google_sql_database" "airbyte_db" {
  name     = var.airbyte_db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "airbyte_user" {
  name     = var.airbyte_db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password[3].result
}

# The generation of password without special characters. This is to avoid issues with the password being used in the connection string.
resource "random_password" "db_password" {
  length  = 18
  special = false
  count   = 4
}
