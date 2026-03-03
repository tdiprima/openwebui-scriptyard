#!/bin/bash
# Starting Open WebUI with auto-mapped Microsoft → OIDC envs

# ---- Load env vars from file ----
ENV_FILE=".env.openwebui"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Missing $ENV_FILE"
  exit 1
fi

echo "📂 Loading environment variables from $ENV_FILE..."
export $(grep -v '^#' "$ENV_FILE" | xargs)

# ---- Convert Microsoft vars to OIDC if needed ----
if [ -n "$MICROSOFT_CLIENT_ID" ] && [ -n "$MICROSOFT_CLIENT_SECRET" ] && [ -n "$MICROSOFT_CLIENT_TENANT_ID" ]; then
  [ -z "$OAUTH_CLIENT_ID" ] && export OAUTH_CLIENT_ID="$MICROSOFT_CLIENT_ID"
  [ -z "$OAUTH_CLIENT_SECRET" ] && export OAUTH_CLIENT_SECRET="$MICROSOFT_CLIENT_SECRET"
  [ -z "$OPENID_PROVIDER_URL" ] && export OPENID_PROVIDER_URL="https://login.microsoftonline.com/${MICROSOFT_CLIENT_TENANT_ID}/v2.0/.well-known/openid-configuration"
fi

# ---- Sanity check for required vars ----
for var in OAUTH_CLIENT_ID OAUTH_CLIENT_SECRET OPENID_PROVIDER_URL; do
  if [ -z "${!var}" ]; then
    echo "❌ Missing required environment variable: $var"
    exit 1
  fi
done

# ---- Run Open WebUI ----
echo "🚀 Starting Open WebUI with OIDC..."

docker stop open-webui
docker rm open-webui
docker rmi 1e27c358a5fe 

docker run -d \
  -p 3000:8080 \
  --env-file "$ENV_FILE" \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main

echo "✅ Open WebUI is now running at http://localhost:3000"

