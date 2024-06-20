#!/bin/bash

# Define your port mappings here
map_airbyte_port="8000:localhost:8000"
map_prefect_port="4200:localhost:4200"
map_proxy_port="8085:localhost:8085"
map_flower_port="5555:localhost:5555"
STG_URL=`cat staging_url.txt`
map_staging_warehouses_port="5433:$STG_URL:5432"
# Add more mappings as needed

# Initialize the port mappings string
port_mappings=""

# Function to add a port mapping
add_port_mapping() {
    if [ -n "$port_mappings" ]; then
        port_mappings="$port_mappings "
    fi
    port_mappings="${port_mappings} -L $1"
}

# Help message function
print_help() {
    echo "Usage: connect.sh [OPTIONS]"
    echo "Options:"
    echo "  --map-all                    Map all ports listed."
    echo "  --map-airbyte                Map the airbyte port."
    echo "  --map-prefect                Map the Prefect UI port."
    echo "  --map-proxy                  Map the Prefect Proxy port."
    echo "  --map-staging-warehouses     Map the RDS staging warehouses port."
    echo "  --map-flower                 Map the Celery Flower port."
    echo "  --help                       Display this help message."
    # Add more options as needed
    exit 0
}

# Process command-line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --map-airbyte)
            add_port_mapping "$map_airbyte_port"
            shift # past argument
            ;;
        --map-prefect)
            add_port_mapping "$map_prefect_port"
            shift # past argument
            ;;
        --map-proxy)
            add_port_mapping "$map_proxy_port"
            shift # past argument
            ;;
        --map-staging-warehouses)
            add_port_mapping "$map_staging_warehouses_port"
            shift # past argument
            ;;
        --map-flower)
            add_port_mapping "$map_flower_port"
            shift # past argument
            ;;
        --map-all)
            add_port_mapping "$map_airbyte_port"
            add_port_mapping "$map_prefect_port"
            add_port_mapping "$map_proxy_port"
            add_port_mapping "$map_staging_warehouses_port"
            add_port_mapping "$map_flower_port"
            shift # past argument
            ;;
        --help)
            print_help
            ;;
        *)    # unknown option
            shift # past argument
            ;;
    esac
done

MACHINE_IP=`cat machineip.txt`
echo "Machine IP: $MACHINE_IP"
# Your basic SSH command
ssh_command="ssh -i ddp.pem ddp@$MACHINE_IP"

# Combine the SSH command with the port mappings
full_command="$ssh_command $port_mappings"

echo "Running command: $full_command"
eval $full_command
