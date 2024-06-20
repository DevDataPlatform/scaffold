#!/bin/bash

# Get the secret from secret manager
get_secret() {
    local secret_name="$1"  
    : "${json_secret:=$(gcloud secrets versions access latest --secret="$secret_name" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)}"
    local value=$(echo "$json_secret")
    echo "$value"    
}

# Get the value from the secret based on the key
get_secret_value() {
    local secret="$1" key="$2" form="$3" 
    if [ "$form" == "json" ]; then
        : "${final_value:=$(echo $secret | jq -r ."$key")}"
  		echo $final_value
    else
        echo "$value"
    fi
}

echo "Fetching variables from Secret Manager..."

PREFECT_DB_CREDENTIALS=$(get_secret "prefect-db-credentials")

export PREFECT_API_DATABASE_CONNECTION_URL=$(get_secret_value "$PREFECT_DB_CREDENTIALS" "PREFECT_API_DATABASE_CONNECTION_URL" "json" )
export PREFECT_WORK_QUEUE_NAME=$PREFECT_WORK_QUEUE_NAME
export PREFECT_POOL_NAME=$PREFECT_POOL_NAME
export PREFECT_PROXY_API_PORT=$PREFECT_PROXY_API_PORT


/opt/prefect/entrypoint.sh prefect server start
