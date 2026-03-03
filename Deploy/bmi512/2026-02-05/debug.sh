echo "Is LiteLLM running?"
docker ps | grep litellm
echo ""

echo "Is the config mounted correctly?"
docker inspect litellm | grep -A5 Mounts
echo ""

echo "Any errors in LiteLLM logs?"
docker logs litellm --tail 30
echo ""

echo "Does LiteLLM see the models?"
curl http://localhost:4000/v1/models
echo ""

echo "Are both containers on the same network?"
docker network inspect shared-net
