# Contribution Guide

Follow these steps to contribute a new example:

## Step 1. Create a New Directory

- In the `examples` folder, create a new directory for your example. Name it based on the data source or use case you're working with.

```bash
mkdir examples/<your-example-name>
```

## Step 2. Create Subdirectories

- Inside your new example directory, create two subdirectories: `datasource` and `ddn`.

```bash
cd examples/<your-example-name>
mkdir datasource ddn
```

## Step 3. Create a `config.yaml`

- In the root of your new example directory, create a `config.yaml` file using the following template:

```yaml
name: <Your example's name> # e.g., Postgres
connector_hub_name: hasura/<name_of_connector> # e.g., hasura/postgres
connector_name: <my_connector> # e.g., my_postgres
# Optional: add any environment variables to be added to the root of the project
env_vars:
  # E.g.
  APP_MY_PG_CONNECTION_URI: "postgresql://postgres:postgres@local.hasura.dev:5432/postgres"
# Optional: map environment variables throughout the application
env_mappings:
  KEY_NEEDED_BY_CONNECTOR: <KEY_FROM_ROOT_ENV>
```

## Step 4. Create a `compose.yaml` for the Data Source

- In the `datasource` directory, create a `compose.yaml` file. This file should define the services required to run your data source, as well as any seed logic for initializing it.

```bash
touch datasource/compose.yaml
```

- Example `compose.yaml` structure:

```yaml
version: "3.8"
services:
  <your-data-source>:
    image: <your-docker-image>
    ports:
      - "5432:5432" # Adjust as needed
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=postgres
```

## Step 5. Add Seed Data

- Add any seed data that needs to be loaded into your data source during initialization. This can either be included directly in your `compose.yaml` or provided as a separate script in the `datasource` folder.

## Step 6. Create a build

Run the build script from the root of the directory and pass your folder as an argument:

```sh
./utils/build.sh examples/<your_new_example>
```

If everything succeeds, viola! You're ready to open a PR and share the example **after you add a README to the
directory** 🎉

Otherwise, take a hard look at the `env_vars` and `env_mappings` in your config.yaml to ensure everything is sorted.
