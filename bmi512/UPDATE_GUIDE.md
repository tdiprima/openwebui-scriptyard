# Open WebUI & LiteLLM Update Guide

This guide covers how to update your Open WebUI and LiteLLM Docker containers.

## Prerequisites

- Docker installed and running
- Existing `.env.openwebui` file
- Existing `~/litellm/config.yaml` file
- Docker network `shared-net` (see setup below)

### Ensure Shared Network Exists

Both Open WebUI and LiteLLM need to communicate on the same Docker network. Before updating, ensure the network exists:

```bash
# Check if network exists
docker network ls | grep shared-net

# If it doesn't exist, create it
docker network create shared-net
```

## Quick Update Commands

### Update Open WebUI

You already have a script for this! Just run:

```bash
./redeploy-open-webui.sh
```

This script automatically:
- Pulls the latest image
- Stops and removes the old container
- Starts a new container with `--network shared-net` included

### Update LiteLLM

```bash
# Pull the latest image
docker pull ghcr.io/berriai/litellm:main-latest

# Stop and remove existing container
docker stop litellm
docker rm litellm

# Restart with the new image (note: --network shared-net is REQUIRED)
docker run -d \
  --name litellm \
  --network shared-net \
  -p 4000:4000 \
  -v ~/litellm/config.yaml:/app/config.yaml \
  --restart unless-stopped \
  ghcr.io/berriai/litellm:main-latest \
  --config /app/config.yaml

# Verify it's running
docker logs litellm --tail 20
curl http://localhost:4000/v1/models
```

**Note:** The `--network shared-net` flag ensures LiteLLM can be reached by Open WebUI.

## Update Both Services

To update everything at once:

```bash
# Ensure shared network exists (both containers need this to communicate)
docker network create shared-net 2>/dev/null || echo "Network already exists"

# Update Open WebUI
./redeploy-open-webui.sh

# Update LiteLLM
docker pull ghcr.io/berriai/litellm:main-latest
docker stop litellm && docker rm litellm
docker run -d \
  --name litellm \
  --network shared-net \
  -p 4000:4000 \
  -v ~/litellm/config.yaml:/app/config.yaml \
  --restart unless-stopped \
  ghcr.io/berriai/litellm:main-latest \
  --config /app/config.yaml
```

**Important:** Both containers MUST be on the `shared-net` network for Open WebUI to communicate with LiteLLM.

## What the Update Process Does

### Open WebUI Update

1. Loads environment variables from `.env.openwebui`
2. Pulls the latest `ghcr.io/open-webui/open-webui:main` image
3. Stops and removes the existing container
4. Starts a new container with:
   - Port mapping: 3000:8080
   - Persistent data volume: `open-webui:/app/backend/data`
   - Network: `shared-net`
   - Auto-restart enabled
   - OIDC authentication configured

### LiteLLM Update

1. Pulls the latest `ghcr.io/berriai/litellm:main-latest` image
2. Stops and removes the existing container
3. Starts a new container with:
   - Port mapping: 4000:4000
   - Config file: `~/litellm/config.yaml`
   - Network: `shared-net`
   - Auto-restart enabled

## Your Data is Safe

Both services use persistent storage:

- **Open WebUI**: Uses a Docker volume `open-webui:/app/backend/data` for user data, conversations, and settings
- **LiteLLM**: Uses a config file at `~/litellm/config.yaml` which is mounted into the container

These are preserved across updates.

## Verification Steps

### Check Open WebUI

```bash
# Check container status
docker ps | grep open-webui

# View recent logs
docker logs open-webui --tail 50

# Test the web interface
open http://localhost:3000
```

### Check LiteLLM

```bash
# Check container status
docker ps | grep litellm

# View recent logs
docker logs litellm --tail 50

# Test the API endpoint
curl http://localhost:4000/v1/models

# Check health
curl http://localhost:4000/health
```

## Rollback (If Needed)

If an update causes issues, you can rollback to a specific version:

### Rollback Open WebUI

```bash
docker stop open-webui && docker rm open-webui

# Use a specific version tag instead of :main
docker run -d \
  --name open-webui \
  -p 3000:8080 \
  --env-file .env.openwebui \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --network shared-net \
  --restart always \
  ghcr.io/open-webui/open-webui:0.3.x
```

### Rollback LiteLLM

```bash
docker stop litellm && docker rm litellm

# Use a specific version tag
docker run -d \
  --name litellm \
  --network shared-net \
  -p 4000:4000 \
  -v ~/litellm/config.yaml:/app/config.yaml \
  --restart unless-stopped \
  ghcr.io/berriai/litellm:v1.x.x \
  --config /app/config.yaml
```

## Troubleshooting

### Container Won't Start

```bash
# Check Docker logs
docker logs open-webui
docker logs litellm

# Check if ports are in use
lsof -i :3000
lsof -i :4000

# Check if network exists
docker network ls | grep shared-net
```

### Network Issues

If containers can't communicate or Open WebUI can't reach LiteLLM:

```bash
# Create the network if it doesn't exist
docker network create shared-net 2>/dev/null

# Ensure both containers are on the same network
docker network connect shared-net open-webui 2>/dev/null
docker network connect shared-net litellm 2>/dev/null

# Verify both containers are on the network
docker network inspect shared-net | grep -A 5 "Containers"

# You should see both 'open-webui' and 'litellm' listed
```

**Why the shared network is critical:**
- Open WebUI needs to communicate with LiteLLM at `http://litellm:4000`
- Without the shared network, containers can't resolve each other by name
- Both `redeploy-open-webui.sh` and the LiteLLM commands include `--network shared-net`

### Environment Variables Not Loading

```bash
# Check if .env.openwebui exists
ls -la .env.openwebui

# Test loading variables
export $(grep -v '^#' .env.openwebui | xargs)
env | grep OAUTH
```

## Update Schedule Recommendations

- **Security updates**: Check weekly
- **Feature updates**: Check monthly
- **Major versions**: Review changelog before updating

## Backup Recommendations

Before major updates:

```bash
# Backup Open WebUI data
docker run --rm -v open-webui:/data -v $(pwd):/backup ubuntu tar czf /backup/open-webui-backup-$(date +%Y%m%d).tar.gz /data

# Backup LiteLLM config
cp ~/litellm/config.yaml ~/litellm/config.yaml.backup-$(date +%Y%m%d)

# Backup environment file
cp .env.openwebui .env.openwebui.backup-$(date +%Y%m%d)
```

## Additional Resources

- Open WebUI Documentation: https://docs.openwebui.com
- LiteLLM Documentation: https://docs.litellm.ai
- Docker Documentation: https://docs.docker.com

## Your Current Configuration

- **Open WebUI**: Running on http://localhost:3000
- **LiteLLM**: Running on http://localhost:4000
- **Network**: shared-net
- **Open WebUI Image**: ghcr.io/open-webui/open-webui:main
- **LiteLLM Image**: ghcr.io/berriai/litellm:main-latest
- **Azure Models**: GPT-5.2, Claude Opus 4.5

---

## Get LiteLLM version

```sh
docker exec -it litellm /bin/bash
pip show litellm
```

<br>
