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
  		echo $final_value
    else
        echo "$value"
    fi
}

echo "Fetching variables from Secret Manager..."
WEB_SECRETS=$(get_secret "webapp-secrets")


export NEXTAUTH_SECRET=$(get_secret_value "$WEB_SECRETS" "NEXTAUTH_SECRET" "json")
export NEXTAUTH_URL=$(get_secret_value "$WEB_SECRETS" "NEXTAUTH_URL" "json")
export CYPRESS_BASE_URL=$(get_secret_value "$WEB_SECRETS" "CYPRESS_BASE_URL" "json")

node server.js