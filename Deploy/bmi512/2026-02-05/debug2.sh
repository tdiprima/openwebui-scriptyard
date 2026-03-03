# Is it running or did it exit?
docker ps -a | grep litellm

# Get ALL logs (not just tail)
docker logs litellm

# Check container status
docker inspect litellm --format '{{.State.Status}} - {{.State.Error}}'
