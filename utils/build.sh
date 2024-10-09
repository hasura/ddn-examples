#!/usr/bin/env bash

# Source the common script
source ./utils/common.sh

# Function to run the build process based on config.yaml
run_build() {
  local config_file=$1
  local ddn_env_file=$2
  local datasource_dir=$3
  local ddn_dir=$4


  # Extract necessary values from config.yaml
  local name=$(get_value_by_key "name" "$config_file")
  local connector_hub_name=$(get_value_by_key "connector_hub_name" "$config_file")
  local connector_name=$(get_value_by_key "connector_name" "$config_file")


  # Create a project in the ddn directory
  create_ddn_project "$datasource_dir" "$ddn_dir"

  # Initialize the connector
  initialize_ddn_connector "$connector_name" "$connector_hub_name"

  
  # Update .env file with env_vars extracted from config.yaml
  update_env_vars "../config.yaml" "$ddn_env_file"


  # Apply env_mappings to YAML files based on config.yaml
  apply_env_mappings_to_yaml_files "../config.yaml" "./app/subgraph.yaml" "./app/connector/$connector_name/compose.yaml" "./app/connector/$connector_name/connector.yaml"


  # Introspect the source and link resources
  introspect_and_add_resources "$connector_name"


  # Build and start the services
  build_and_run_ddn

}

# Main logic
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service_directory>"
  exit 1
fi

# Use the argument to define the service directory
service_dir=$1

config_file="$service_dir/config.yaml"
ddn_env_file=".env"
datasource_dir="$service_dir/datasource"
ddn_dir="$service_dir/ddn"

# Validate that config.yaml exists
if [ ! -f "$config_file" ]; then
  echo "Error: config.yaml not found in $service_dir"
  exit 1
fi

# Run the build process with the selected configuration
run_build "$config_file" "$ddn_env_file" "$datasource_dir" "$ddn_dir"
