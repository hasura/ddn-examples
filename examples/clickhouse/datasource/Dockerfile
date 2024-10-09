FROM clickhouse/clickhouse-server:latest

# Set default username and password
ENV CLICKHOUSE_USER=user
ENV CLICKHOUSE_PASSWORD=password

# Copy the CSV file into the container
COPY clickhouse_seed.csv /data/clickhouse_seed.csv

# Copy an initialization script to the container
COPY init_script.sh /docker-entrypoint-initdb.d/

# Ensure the init script is executable
RUN chmod +x /docker-entrypoint-initdb.d/init_script.sh
