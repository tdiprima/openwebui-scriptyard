#!/usr/bin/env bash
#
# setup-open-webui.sh
#
# Installs Docker (if not already present) and deploys Open WebUI
# on Linux, pointed at an existing Ollama instance.
#
# Usage:
#   sudo ./setup-open-webui.sh [OLLAMA_URL] [WEBUI_PORT]
#
# Examples:
#   sudo ./setup-open-webui.sh
#       -> assumes Ollama at http://host.docker.internal:11434, WebUI on port 3000
#
#   sudo ./setup-open-webui.sh http://192.168.1.50:11434 8080
#       -> Ollama on a remote host, WebUI exposed on port 8080
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
OLLAMA_URL="${1:-http://host.docker.internal:11434}"
WEBUI_PORT="${2:-3000}"
CONTAINER_NAME="open-webui"
VOLUME_NAME="open-webui"
IMAGE="ghcr.io/open-webui/open-webui:main"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo -e "\n[+] $*"; }
warn() { echo -e "\n[!] $*" >&2; }

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. Install Docker if it's not already present
# ---------------------------------------------------------------------------
if command -v docker &>/dev/null; then
  log "Docker is already installed, skipping install step."
else
  log "Installing Docker CE..."
  dnf -y install dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable --now docker
fi

# ---------------------------------------------------------------------------
# 2. Open the WebUI port in firewalld (if firewalld is active)
# ---------------------------------------------------------------------------
if systemctl is-active --quiet firewalld; then
  log "Opening TCP port ${WEBUI_PORT} in firewalld..."
  firewall-cmd --add-port="${WEBUI_PORT}/tcp" --permanent
  firewall-cmd --reload
else
  warn "firewalld is not active; skipping firewall configuration."
  warn "If you enable a firewall later, remember to open port ${WEBUI_PORT}/tcp."
fi

# ---------------------------------------------------------------------------
# 3. Verify the Ollama instance is reachable before deploying
# ---------------------------------------------------------------------------
log "Checking connectivity to Ollama at ${OLLAMA_URL} ..."
if curl -fsS --max-time 5 "${OLLAMA_URL}/api/tags" >/dev/null 2>&1; then
  log "Ollama is reachable."
else
  warn "Could not reach ${OLLAMA_URL}/api/tags from this host."
  warn "This may still work once inside the container (e.g. host.docker.internal"
  warn "resolves differently than from the host shell), but double-check:"
  warn "  - Ollama is running and OLLAMA_HOST is set to 0.0.0.0:11434 if remote/containerized"
  warn "  - Any firewall between this host and the Ollama instance allows port 11434"
fi

# ---------------------------------------------------------------------------
# 4. Remove any existing container with the same name (idempotent re-runs)
# ---------------------------------------------------------------------------
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  log "Existing container '${CONTAINER_NAME}' found, removing it..."
  docker rm -f "${CONTAINER_NAME}"
fi

# ---------------------------------------------------------------------------
# 5. Run Open WebUI
# ---------------------------------------------------------------------------
log "Starting Open WebUI container..."
docker run -d \
  -p "${WEBUI_PORT}:8080" \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL="${OLLAMA_URL}" \
  -v "${VOLUME_NAME}:/app/backend/data:Z" \
  --name "${CONTAINER_NAME}" \
  --restart always \
  "${IMAGE}"

# ---------------------------------------------------------------------------
# 6. Done
# ---------------------------------------------------------------------------
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

log "Open WebUI is starting up."
echo "    Local:   http://localhost:${WEBUI_PORT}"
[[ -n "${SERVER_IP}" ]] && echo "    Network: http://${SERVER_IP}:${WEBUI_PORT}"
echo ""
echo "    Connected to Ollama at: ${OLLAMA_URL}"
echo ""
echo "First user to sign up becomes the admin account."
echo ""
echo "To check logs:   docker logs -f ${CONTAINER_NAME}"
echo "To stop:         docker stop ${CONTAINER_NAME}"
echo "To test the container's view of Ollama:"
echo "    docker exec -it ${CONTAINER_NAME} curl ${OLLAMA_URL}/api/tags"
