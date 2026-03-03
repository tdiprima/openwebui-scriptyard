# 1. Stop and remove the broken container
docker stop litellm 2>/dev/null; docker rm litellm 2>/dev/null

# 2. Start LiteLLM correctly (no --restart flag)
docker run -d \
  --name litellm \
  --network shared-net \
  -p 4000:4000 \
  -v ~/litellm/config.yaml:/app/config.yaml \
  --restart unless-stopped \
  ghcr.io/berriai/litellm:main-latest \
  --config /app/config.yaml

# 3. Verify it's running
docker logs litellm --tail 20

# 4. Test the models endpoint
curl http://localhost:4000/v1/models
