# Example: `Postgres`

This directory contains a working setup for `Postgres` with Hasura DDN. It uses Docker Compose to spin up the service and connect it with Hasura DDN through the provided configuration files.

## Quick Start

To run this specific example:

1. **Ensure the Repository is Cloned**

   If you haven't already cloned the repository, do so:

   ```bash
   git clone https://github.com/hasura/ddn-examples.git
   ```

1. **Run the Example**

   Use the build script from the root of the repository to spin up the data source and connect it to Hasura DDN:

   ```bash
   ./utils/build.sh examples/postgres
   ```

   This will start all necessary services and apply the default configuration.

## Directory Structure

```plaintext
<example-name>/
  ├── datasource/
  │   └── compose.yaml  # Docker Compose file for launching the data source
  ├── ddn/
  │   └── ...           # Hasura DDN configuration
  └── config.yaml       # Metadata, environment variables, and connector settings
```

### Key Files

- **datasource/compose.yaml**: Defines the Docker Compose setup for the `<Example Name>` service.
- **ddn/**: Contains the configuration necessary to link the data source with Hasura DDN.
- **config.yaml**: This file includes metadata and environment variable mappings required for running the example.

## Customization

You can modify `config.yaml` to customize environment variables, metadata, or connector settings to suit your use case.

## Troubleshooting

If you encounter any issues:

- Review the configuration files in the `ddn/` directory for any potential issues.
- Check Docker logs to diagnose service-related problems.
- Ensure that Docker and Docker Compose are installed and running correctly.
- Check for open issues in the main repository or raise a new one if necessary.

## Requirements

- **Docker** and **Docker Compose** must be installed to run this example.
- The [Hasura DDN CLI](https://hasura.io/docs/3.0/cli/installation) must be installed to manage DDN services.
