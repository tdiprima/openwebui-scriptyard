#!/bin/bash

# ---- Load env vars from file ----
ENV_FILE=".env.openwebui"

echo "📂 Loading environment variables from $ENV_FILE..."
export $(grep -v '^#' "$ENV_FILE" | xargs)

# -----------------------------
# Docker Configuration
# -----------------------------
IMAGE="ghcr.io/open-webui/open-webui:main"
CONTAINER="open-webui"

echo "Pulling latest Docker image..."
docker pull "$IMAGE"

echo "Stopping existing container (if running)..."
docker stop "$CONTAINER" 2>/dev/null

echo "Removing existing container (if present)..."
docker rm "$CONTAINER" 2>/dev/null

echo "Starting new container..."
docker run -d \
  --name "$CONTAINER" \
  -p 3000:8080 \
  --env-file "$ENV_FILE" \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --network shared-net \
  --restart always \
  "$IMAGE"

echo "Application redeployed successfully ✅"
