# Dalgo DB credentials

resource "google_secret_manager_secret" "db_credentials" {
  secret_id = "dalgo-db-credentials"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "dalgo_db_credentials" {
  secret = google_secret_manager_secret.db_credentials.name
  secret_data = jsonencode({
    DBUSER          = var.db_user
    DBPASSWORD      = random_password.db_password[1].result
    DBHOST          = google_sql_database_instance.postgres.ip_address[0].ip_address
    DBADMINUSER     = "postgres"
    DBADMINPASSWORD = random_password.db_password[0].result
    DBPORT          = var.db_port
    DBNAME          = var.db_name
  })
}

resource "google_secret_manager_secret" "prefect_db_credentials" {
  secret_id = "prefect-db-credentials"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "prefect_db_credentials" {
  secret = google_secret_manager_secret.prefect_db_credentials.name
  secret_data = jsonencode({
    DBUSER                              = var.prefect_db_user
    DBPASSWORD                          = random_password.db_password[2].result
    PREFECT_API_DATABASE_CONNECTION_URL = "postgresql+asyncpg://${var.prefect_db_user}:${random_password.db_password[2].result}@${google_sql_database_instance.postgres.ip_address[0].ip_address}:${var.db_port}/${var.prefect_db_name}"
  })
}

resource "google_secret_manager_secret" "airbyte_db_credentials" {
  secret_id = "airbyte-db-credentials"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "airbyte_db_credentials" {
  secret = google_secret_manager_secret.airbyte_db_credentials.name
  secret_data = jsonencode({
    DBHOST       = google_sql_database_instance.postgres.ip_address[0].ip_address
    DBUSER       = var.airbyte_db_user
    DBPASSWORD   = random_password.db_password[3].result
    DATABASE     = var.airbyte_db_name
    DATABASE_URL = "jdbc:postgresql://${google_sql_database_instance.postgres.ip_address[0].ip_address}:${var.db_port}/${var.airbyte_db_name}?ssl=true&sslmode=require"

  })
}

