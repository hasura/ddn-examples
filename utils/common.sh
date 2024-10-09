#!/usr/bin/env bash

# This helper function allows you to get value by key from a YAML file
get_value_by_key() {
  local key=$1
  local yaml_file=$2
  grep "^$key:" "$yaml_file" | sed -E 's/^[^:]+: *//'
}

# This function allows you to get the value by key from a .env file
get_env_value_by_key() {
  local key=$1
  local env_file=$2

  if [ ! -f "$env_file" ]; then
    echo "Error: .env file not found at $env_file"
    exit 1
  fi

  grep "^$key=" "$env_file" | sed -E 's/^[^=]+=(.*)/\1/'
}

# This function allows you to replace or append the value in a .env file
replace_or_append_env_var() {
  local key=$1
  local value=$2
  local env_file=$3

  # Check if the key exists and replace the value if it does
  if grep -q "^$key=" "$env_file"; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|^$key=.*|$key=$value|" "$env_file"  # For macOS
    else
      sed -i "s|^$key=.*|$key=$value|" "$env_file"  # For Linux
    fi
    echo "Updated $key in $env_file"
  else
    # Append a newline if the file doesn't already end with one
    if [ -n "$(tail -c 1 "$env_file")" ]; then
      echo >> "$env_file"
    fi
    # Append the key-value pair
    echo "$key=$value" >> "$env_file"
    echo "Added $key to $env_file"
  fi
}

# Function to update .env file with env_vars from config.yaml
update_env_vars() {
  local config_file=$1
  local ddn_env_file=$2

  # Check if the .env file exists in the ddn directory, and create it if it doesn't
  if [ ! -f "$ddn_env_file" ]; then
    echo "Error: .env file not found at $ddn_env_file"
    exit 1
  fi

  # Debugging output to check what's being parsed
  echo "Parsing env_vars from $config_file"

  # Extract env_vars from config.yaml using proper indentation handling
  awk '/^env_vars:/ {flag=1; next} /^[a-zA-Z0-9_]+:/ {flag=0} flag {print}' "$config_file" | while IFS=: read -r key value; do
    # Trim whitespace and check if both key and value are non-empty
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    if [[ -n "$key" && -n "$value" ]]; then
      replace_or_append_env_var "$key" "$value" "$ddn_env_file"
      echo "Added $key to $ddn_env_file"
    else
      echo "Skipping empty key or value: key='$key', value='$value'"
    fi
  done
}

# Function to apply env_mappings to the relevant YAML files
apply_env_mappings_to_yaml_files() {
  local config_file=$1
  local subgraph_file=$2
  local compose_file=$3
  local connector_yaml=$4

  # Extract env_mappings from config.yaml and apply changes to YAML files
  while IFS=: read -r key value; do
    key=$(echo "$key" | xargs)    # Trim whitespace
    value=$(echo "$value" | xargs) # Trim whitespace

    # Call the necessary functions
    add_env_mapping_to_yaml "$value" "$subgraph_file"
    add_env_to_compose "$key" "$value" "$compose_file"
    add_env_to_connector_yaml "$key" "$value" "$connector_yaml"
  done < <(awk '/env_mappings:/ {flag=1; next} /^[^ ]/ {flag=0} flag {print}' "$config_file")
}

# Function to create the DDN project and initialize the supergraph
create_ddn_project() {
  local datasource_dir=$1
  local ddn_dir=$2

  echo "🧰 Building the project"

  # Use the correct path for the datasource directory
  if [ ! -f "$datasource_dir/compose.yaml" ]; then
    echo "Error: compose.yaml not found in $datasource_dir"
    exit 1
  fi

  docker compose -f "$datasource_dir/compose.yaml" up -d --build

  echo "⏳Giving the data source time to come online..."

  sleep 15

  # Check if ddn directory exists and clean it up
  if [ ! -d "$ddn_dir" ]; then
    echo "Error: ddn directory not found"
    exit 1
  fi

  # Remove everything in the ddn directory, but keep the empty dir
  find "$ddn_dir" -mindepth 1 -delete

  # In the empty DDN directory, run ddn supergraph init .
  cd "$ddn_dir" || exit
  ddn supergraph init .
}

# Function to initialize the connector after the project is created
initialize_ddn_connector() {
  local connector_name=$1
  local connector_hub_name=$2

  echo "🔌 Initializing the connector: $connector_name"
  ddn connector init "$connector_name" --hub-connector "$connector_hub_name" --add-to-compose-file ./compose.yaml --no-prompt
}

# Function to introspect and link resources for the connector
introspect_and_add_resources() {
  local connector_name=$1
  ddn connector introspect "$connector_name"
  ddn connector-link add-resources "$connector_name"
}

# Function to build and start the services
build_and_run_ddn() {
  ddn supergraph build local
  ddn run docker-start
}

# Function to add environment mappings to YAML files
add_env_mapping_to_yaml() {
  local env_var=$1
  local yaml_file=$2

  # Check if the env var already exists in the yaml file
  if grep -q "$env_var:" "$yaml_file"; then
    echo "Env var $env_var already exists in $yaml_file"
  else
    # Insert the new env var with correct indentation and formatting under envMapping
    awk -v env_var="$env_var" '/envMapping:/ {
      print $0
      print "    " env_var ":"
      print "      fromEnv: " env_var
      next
    }1' "$yaml_file" > temp.yaml && mv temp.yaml "$yaml_file"
    echo "Added $env_var to envMapping in $yaml_file"
  fi
}

# Function to add environment variables to docker-compose files
add_env_to_compose() {
  local unprefixed_env_var=$1
  local prefixed_env_var=$2
  local yaml_file=$3

  # Check if the unprefixed env var already exists in the yaml file
  if grep -q "$unprefixed_env_var:" "$yaml_file"; then
    echo "Env var $unprefixed_env_var already exists in $yaml_file"
  else
    # Insert the new environment variable into the environment section
    awk -v unprefixed_env_var="$unprefixed_env_var" -v prefixed_env_var="$prefixed_env_var" '/environment:/ {
      print $0
      print "      " unprefixed_env_var ": $" prefixed_env_var
      next
    }1' "$yaml_file" > temp_compose.yaml && mv temp_compose.yaml "$yaml_file"

    echo "Added $unprefixed_env_var with $prefixed_env_var to the environment section of $yaml_file"
  fi
}

# Function to add environment variables to connector YAML files
add_env_to_connector_yaml() {
  local unprefixed_env_var=$1
  local prefixed_env_var=$2
  local yaml_file=$3

  # Check if the unprefixed env var already exists in the yaml file
  if grep -q "$unprefixed_env_var:" "$yaml_file"; then
    echo "Env var $unprefixed_env_var already exists in $yaml_file"
  else
    # Insert the new env var under envMapping
    awk -v unprefixed_env_var="$unprefixed_env_var" -v prefixed_env_var="$prefixed_env_var" '/envMapping:/ {
      print $0
      print "    " unprefixed_env_var ":"
      print "      fromEnv: " prefixed_env_var
      next
    }1' "$yaml_file" > temp_connector.yaml && mv temp_connector.yaml "$yaml_file"

    echo "Added $unprefixed_env_var with $prefixed_env_var to envMapping in $yaml_file"
  fi
}
