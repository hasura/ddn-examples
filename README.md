# Examples of Hasura DDN

This repository provides ready-to-use examples for configuring and running various data sources with Hasura DDN's
[native data connectors](https://hasura.io/connectors). Each example includes a Docker Compose setup to easily spin up the data source
and get started with Hasura DDN in no time.

## Quick Start

To get an example up and running instantly, follow these steps:

1. **Clone the Repository**

   Start by cloning this repository to your local machine:

   ```bash
   git clone https://github.com/hasura/ddn-examples.git
   ```

1. **Choose an Example**

   Look through the `examples/` directory to choose the data source you want to run. Each folder contains a different example.

1. **Run the Example**

   Use the convenient build script from the root of the repo to start the data services and re-create the Hasura project with all the default
   configurations.

   ```bash
   # ensure ./utils/build.sh has been given proper permissions: chmod +x
   ./utils/build.sh examples/<your-choice>
   ```

   Your data source and Hasura DDN instance should be running locally after pulling down all necessary images.

## Example Structure

Each example follows a consistent structure:

```plaintext
examples/
  ├── <example-name>/
  │   ├── datasource/
  │   │   └── compose.yaml  # Docker Compose file to run the data source
  │   ├── ddn/
  │   │   └── ...           # DDN configuration files
  │   └── config.yaml       # Metadata and environment variables
```

- **datasource/**: Contains the Docker Compose file and any related scripts to launch the data source.
- **ddn/**: Contains configuration details for connecting the data source to Hasura DDN.
- **config.yaml**: Defines metadata, environment variables, and connector settings for Hasura.

## Example Data Sources

- PostgreSQL
- MongoDB
- ClickHouse
- ... and more!

Each data source is self-contained and ready to use, with pre-configured seed data where applicable.

## Troubleshooting

If you encounter any issues while running an example, check the `ddn/` directory for specific configuration instructions or open an issue in this repository.

---

## Additional Notes

- **Docker** is required to run the examples. Ensure that you have Docker and Docker Compose installed.
- You'll also need the [Hasura DDN CLI](https://hasura.io/docs/3.0/cli/installation) installed.
- You can modify the `config.yaml` file to adjust environment variables or data source settings as needed.

For more detailed configuration, refer to the Hasura DDN documentation.
