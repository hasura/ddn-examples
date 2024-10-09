#!/bin/bash

# Wait for ClickHouse server to be ready
sleep 5

# Create the table to match the CSV schema for client activity
clickhouse-client --user=$CLICKHOUSE_USER --password=$CLICKHOUSE_PASSWORD --query="
CREATE TABLE IF NOT EXISTS client_activity (
    client_id UInt32,
    session_id String,
    activity_type String,
    timestamp DateTime,
    page_visited String,
    referrer String
) ENGINE = MergeTree()
ORDER BY timestamp;
"

# Import the CSV data into the table
clickhouse-client --user=$CLICKHOUSE_USER --password=$CLICKHOUSE_PASSWORD --query="INSERT INTO client_activity FORMAT CSV" < /data/clickhouse_seed.csv
