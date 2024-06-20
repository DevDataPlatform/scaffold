# Airbyte secrets
resource "google_secret_manager_secret" "airbyte_secrets" {
  secret_id = "airbyte-secrets"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "airbyte_secrets" {
  secret = google_secret_manager_secret.airbyte_secrets.name
  secret_data = jsonencode({
    AIRBYTE_SERVER_HOST       = google_compute_instance.airbyte.network_interface.0.network_ip
    AIRBYTE_SERVER_PORT       = 8000
    AIRBYTE_SERVER_APIVER     = "v1"
    AIRBYTE_API_TOKEN         = "NA"
    AIRBYTE_DESTINATION_TYPES = "bigquery,postgres"
  })

  lifecycle {
    ignore_changes = [secret_data]

  }
}

# Webapp Variables
# Most of the variables are set to empty strings or false. These will be updated with the actual values manually.
resource "google_secret_manager_secret" "webapp_secrets" {
  secret_id = "webapp-secrets"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "webapp_secrets" {
  secret = google_secret_manager_secret.webapp_secrets.name
  secret_data = jsonencode({
    NEXTAUTH_SECRET                   = ""
    DJANGOSECRET                      = random_password.django_secret.result
    DEBUG                             = false
    PRODUCTION                        = false
    DEV_SECRETS_DIR                   = "secrets"
    PREFECT_PROXY_API_URL             = "http://prefect_proxy:4300"
    PREFECT_HTTP_TIMEOUT              = 5
    CLIENTDBT_ROOT                    = "dbt/dbt"
    DBT_VENV                          = "dbt/bin/activate"
    SIGNUPCODE                        = random_password.signup_code[0].result
    CREATEORG_CODE                    = random_password.signup_code[1].result
    FRONTEND_URL                      = "http://app:3000"
    PREFECT_NOTIFICATIONS_WEBHOOK_KEY = ""
    SUPERSET_USAGE_DASHBOARD_API_URL  = ""
    SUPERSET_USAGE_CREDS_SECRET_ID    = ""
    FIRST_ORG_NAME                    = ""
    FIRST_USER_EMAIL                  = ""
    REDIS_HOST                        = "redis_server"
    REDIS_PORT                        = 6379
    CANVAS_LOCK                       = false
    USE_AWS_SECRETS_MANAGER           = false
    NEXTAUTH_URL                      = var.domain
    CYPRESS_BASE_URL                  = var.domain
    FIRST_USER_PASSWORD               = random_password.password.result
    FIRST_USER_ROLE                   = "super-admin"
    PREFECT_WORKER_POOL_NAME          = "dalgo_work_pool"

  })

  lifecycle {
    ignore_changes = [secret_data]

  }
}

# demo account
resource "google_secret_manager_secret" "demo_account" {
  secret_id = "demo-account"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "demo_account" {
  secret = google_secret_manager_secret.demo_account.name
  secret_data = jsonencode({
    DEMO_SIGNUPCODE               = random_password.signup_code[2].result
    DEMO_AIRBYTE_SOURCE_TYPES     = ""
    DEMO_SENDGRID_SIGNUP_TEMPLATE = ""
    DEMO_SUPERSET_USERNAME        = ""
    DEMO_SUPERSET_PASSWORD        = ""

  })

  lifecycle {
    ignore_changes = [secret_data]

  }
}


# sendgrid secrets
resource "google_secret_manager_secret" "sendgrid_secrets" {
  secret_id = "sendgrid-secrets"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

# The secret data is set to empty strings. These will be updated with the actual values manually.
# The templates are template ids from sendgrid dynamic templates
resource "google_secret_manager_secret_version" "sendgrid_secrets" {
  secret = google_secret_manager_secret.sendgrid_secrets.name
  secret_data = jsonencode({
    SENDGRID_APIKEY                    = ""
    SENDGRID_SENDER                    = ""
    SENDGRID_RESET_PASSWORD_TEMPLATE   = ""
    SENDGRID_SIGNUP_TEMPLATE           = ""
    SENDGRID_INVITE_USER_TEMPLATE      = ""
    SENDGRID_YOUVE_BEEN_ADDED_TEMPLATE = ""
  })

  lifecycle {
    ignore_changes = [secret_data]

  }
}

# random password
resource "random_password" "django_secret" {
  length           = 32
  special          = true
  override_special = "_%@"
}

# random code
resource "random_password" "signup_code" {
  length           = 6
  special          = false
  override_special = ""
  count            = 3
}

resource "random_password" "password" {
  length  = 8
  special = true
}
