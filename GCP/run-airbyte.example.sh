#!/usr/bin/env bash
set -e

# Check the mode of deployment 
ENVIRONMENT=$1

# Function to get value from config file
function parse_config() {
	local section_name="$1" key="$2"

 	: "${value:=$(awk '/^\['${section_name}'\]/{f=1} f==1&&/^'${key}'/{print $3;exit}' "config/project_config.cfg")}"
 	echo $value
}

# Run airbyte platform shell script to download necessary files
(./run-ab-platform.sh)

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
  		echo $final_value
    else
        echo "$value"
    fi
}

# Get the secret
DB_SECRETS=$(get_secret "airbyte-db-credentials")

# GET airbyte metadata DB credentials
current_env=$(echo $ENVIRONMENT | tr '[:upper:]' '[:lower:]')
export DATABASE_HOST=$(get_secret_value "$DB_SECRETS" "DBHOST" "json")
export DATABASE_USER=$(get_secret_value "$DB_SECRETS" "DBUSER" "json")
export DATABASE_PASSWORD=$(get_secret_value "$DB_SECRETS" "DBPASSWORD" "json")
export DATABASE=$(get_secret_value "$DB_SECRETS" "DATABASE" "json")
export DATABASE_PORT="5432"
export AIRBYTE_WEB_APP_PORT="8000"
export DATABASE_URL=$(get_secret_value "$DB_SECRETS" "DATABASE_URL" "json")

echo $DATABASE_URL

# If blank parameter, build in dev mode 
if [ "${ENVIRONMENT}" = "DEV" ]
then
	# (cd ./airbyte && docker compose -p "${PROJECT_NAME}" up -d)
	docker compose -f docker-compose.yaml -p "${PROJECT_NAME}" up -d

elif [ "${ENVIRONMENT}" = "PROD" ]
then
	docker compose -f docker-compose.yaml -p "${PROJECT_NAME}" up -d init bootloader worker server airbyte-temporal airbyte-cron airbyte-connector-builder-server
else

	echo "Invalid parameter"

fi

if [ -e config.cfg ]
then
	rm config.cfg
fi