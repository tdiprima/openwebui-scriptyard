# Create config directory
mkdir -p ~/litellm

# Create the config file
cat > ~/litellm/config.yaml << 'EOF'
model_list:
  # Azure OpenAI - GPT-5.2
  - model_name: gpt-5.2
    litellm_params:
      model: azure/gpt-5.2
      api_base: "https://bmi512sp2026.cognitiveservices.azure.com" 
      api_key: "API_KEY" 
      api_version: "2025-04-01-preview"

  # Azure Anthropic - Claude Opus 4.5
  - model_name: claude-opus-4-5
    litellm_params:
      model: claude-opus-4-5
      api_base: https://bmi512sp2026.services.ai.azure.com/anthropic/
      api_key: API_KEY
      custom_llm_provider: anthropic
EOF

# Stop the old container
docker stop litellm && docker rm litellm

# Start with the config mounted
docker run -d \
  --name litellm \
  -p 4000:4000 \
  -v ~/litellm/config.yaml:/app/config.yaml \
  ghcr.io/berriai/litellm:main-latest \
  --restart always \
  --config /app/config.yaml

sleep 5

docker network connect shared-net litellm
