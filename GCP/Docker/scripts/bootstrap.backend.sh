#!/bin/bash
set -e

# Function to add any cleanup actions
function cleanup() {
    echo "Cleanup."
}
trap cleanup EXIT

# Initialize gcloud

# Get the secret from secret manager
function get_secret() {
    local secret_name="$1"  
    : "${json_secret:=$(gcloud secrets versions access latest --secret="$secret_name" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)}"
    local value=$(echo "$json_secret")
    echo "$value"    
}

# Get the value from the secret based on the key
function get_secret_value() {
    local secret="$1" key="$2" form="$3" 
    if [ "$form" == "json" ]; then
        : "${final_value:=$(echo $secret | jq -r ."$key")}"
  		echo "$final_value"
    else
        echo "$value"
    fi
}



echo "Fetching variables from Secret Manager..."

WEB_SECRETS="$(get_secret "webapp-secrets")"
# DEMO_SECRETS=$(get_secret "demo-account")
SENDGRID_SECRETS=$(get_secret "sendgrid-secrets")
AIRBYTE_SECRETS=$(get_secret "airbyte-secrets")
DALGO_DB_CREDENTIALS=$(get_secret "dalgo-db-credentials")


# Fetch secret from Secret Manager at runtime
export DJANGOSECRET=$(get_secret_value "$WEB_SECRETS" "DJANGOSECRET" "json")
export DEBUG=$(get_secret_value "$WEB_SECRETS" "DEBUG" "json")
export PRODUCTION=$(get_secret_value "$WEB_SECRETS" "PRODUCTION" "json" )
export DEV_SECRETS_DIR=$(get_secret_value "$WEB_SECRETS" "DEV_SECRETS_DIR" "json" )
export PREFECT_PROXY_API_URL=$(get_secret_value "$WEB_SECRETS" "PREFECT_PROXY_API_URL" "json" )
export PREFECT_HTTP_TIMEOUT=$(get_secret_value "$WEB_SECRETS" "PREFECT_HTTP_TIMEOUT" "json" )
export CLIENTDBT_ROOT=$(get_secret_value "$WEB_SECRETS" "CLIENTDBT_ROOT" "json" )
export DBT_VENV=$(get_secret_value "$WEB_SECRETS" "DBT_VENV" "json" )
export SIGNUPCODE=$(get_secret_value "$WEB_SECRETS" "SIGNUPCODE" "json" )
export CREATEORG_CODE=$(get_secret_value "$WEB_SECRETS" "CREATEORG_CODE" "json" )
export FRONTEND_URL=$(get_secret_value "$WEB_SECRETS" "FRONTEND_URL" "json" )
export PREFECT_NOTIFICATIONS_WEBHOOK_KEY=$(get_secret_value "$WEB_SECRETS" "PREFECT_NOTIFICATIONS_WEBHOOK_KEY" "json" )
export FIRST_ORG_NAME=$(get_secret_value "$WEB_SECRETS" "FIRST_ORG_NAME" "json" )
export FIRST_USER_EMAIL=$(get_secret_value "$WEB_SECRETS" "FIRST_USER_EMAIL" "json" )
export REDIS_HOST=$(get_secret_value "$WEB_SECRETS" "REDIS_HOST" "json" )
export REDIS_PORT=$(get_secret_value "$WEB_SECRETS" "REDIS_PORT" "json" )
export CANVAS_LOCK=$(get_secret_value "$WEB_SECRETS" "CANVAS_LOCK" "json" )
export SUPERSET_USAGE_DASHBOARD_API_URL=$(get_secret_value "$WEB_SECRETS" "SUPERSET_USAGE_DASHBOARD_API_URL" "json" )
export SUPERSET_USAGE_CREDS_SECRET_ID=$(get_secret_value "$WEB_SECRETS" "SUPERSET_USAGE_CRED_SECRET_ID" "json" )
export NEXTAUTH_SECRET=$(get_secret_value "$WEB_SECRETS" "NEXTAUTH_SECRET" "json" )
export USE_AWS_SECRETS_MANAGER=$(get_secret_value "$WEB_SECRETS" "USE_AWS_SECRETS_MANAGER" "json" )
export FIRST_USER_PASSWORD=$(get_secret_value "$WEB_SECRETS" "FIRST_USER_PASSWORD" "json" )
export FIRST_USER_ROLE=$(get_secret_value "$WEB_SECRETS" "FIRST_USER_ROLE" "json" )

echo "Fetching Dalgo DB variables from Secret Manager..."


export DBNAME=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBNAME" "json" )
export DBUSER=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBUSER" "json" )
export DBPASSWORD=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBPASSWORD" "json" )
export DBHOST=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBHOST" "json" )
export DBPORT=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBPORT" "json" )
export DBADMINUSER=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBADMINUSER" "json" )
export DBADMINPASSWORD=$(get_secret_value "$DALGO_DB_CREDENTIALS" "DBADMINPASSWORD" "json" )

echo "Fetching Airbyte variables from Secret Manager..."
export AIRBYTE_SERVER_HOST=$(get_secret_value "$AIRBYTE_SECRETS" "AIRBYTE_SERVER_HOST" "json" )
export AIRBYTE_SERVER_PORT=$(get_secret_value "$AIRBYTE_SECRETS" "AIRBYTE_SERVER_PORT" "json" )
export AIRBYTE_SERVER_APIVER=$(get_secret_value "$AIRBYTE_SECRETS" "AIRBYTE_SERVER_APIVER" "json" )
export AIRBYTE_API_TOKEN=$(get_secret_value "$AIRBYTE_SECRETS" "AIRBYTE_API_TOKEN" "json" )
export AIRBYTE_DESTINATION_TYPES=$(get_secret_value "$AIRBYTE_SECRETS" "AIRBYTE_DESTINATION_TYPES" "json" )


echo "Fetching Sendgrid variables from Secret Manager..."

export SENDGRID_APIKEY=$(get_secret_value "$SENDGRID_SECRETS" "SENDGRID_APIKEY" "json" )
export SENDGRID_SENDER=$(get_secret_value "$SENDGRID_SECRETS" "SENDGRID_SENDER" "json" )
export SENDGRID_RESET_PASSWORD_TEMPLATE=$(get_secret_value "$SENDGRID_SECRETS" "SENDGRID_RESET_PASSWORD_TEMPLATE" "json" )
export SENDGRID_SIGNUP_TEMPLATE=$(get_secret_value "$SENDGRID_SECRETS" "SENDGRID_SIGNUP_TEMPLATE" "json" )
export SENDGRID_INVITE_USER_TEMPLATE=$(get_secret_value "$SENDGRID_SECRETS" "SENDGRID_INVITE_USER_TEMPLATE" "json" )
export SENDGRID_YOUVE_BEEN_ADDED_TEMPLATE=$(get_secret_value "$SENDGRID_SECRETS" "SENDGRID_YOUVE_BEEN_ADDED_TEMPLATE" "json" )




# DEMO ACCOUNTS
# export DEMO_SIGNUPCODE=$(get_secret_value "$DEMO_SECRETS" "DEMO_SIGNUPCODE" "json" )
# export DEMO_AIRBYTE_SOURCE_TYPES=$(get_secret_value "$DEMO_SECRETS" "DEMO_AIRBYTE_SOURCE_TYPES" "json" )
# export DEMO_SENDGRID_SIGNUP_TEMPLATE=$(get_secret_value "$DEMO_SECRETS" "DEMO_SENDGRID_SIGNUP_TEMPLATE" "json" )
# export DEMO_SUPERSET_USERNAME=$(get_secret_value "$DEMO_SECRETS" "DEMO_SUPERSET_USERNAME" "json" )
# export DEMO_SUPERSET_PASSWORD=$(get_secret_value "$DEMO_SECRETS" "DEMO_SUPERSET_PASSWORD" "json" )

# Execute the command provided as CMD in Dockerfile
exec "$@"
