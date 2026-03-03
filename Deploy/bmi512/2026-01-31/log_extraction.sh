#!/bin/bash

# -----------------------------
# Container Log Extraction
# -----------------------------
CONTAINER="open-webui"
OUTPUT_FILE="logs_last_hour.txt"

echo "Collecting Docker logs for the last 1 hour..."

docker logs --timestamps --since 1h "$CONTAINER" > "$OUTPUT_FILE"

echo "Logs saved to $OUTPUT_FILE ✅"
