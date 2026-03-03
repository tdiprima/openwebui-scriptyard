docker run -d \
  --name litellm \
  --restart always \
  -p 4000:4000 \
  -e AZURE_API_KEY="AZURE_API_KEY" \
  -e AZURE_API_BASE="https://bmi512sp2026.cognitiveservices.azure.com" \
  -e AZURE_API_VERSION="2025-04-01-preview" \
  ghcr.io/berriai/litellm:main-latest \
  --model azure/gpt-5.2
