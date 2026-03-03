#!/bin/bash

# docker stop pipelines
# docker rm pipelines
# docker rmi 4bcc7f778d03 
# docker run -d -p 9099:9099 --add-host=host.docker.internal:host-gateway -v pipelines:/app/pipelines --name pipelines --restart always ghcr.io/open-webui/pipelines:main

docker stop open-webui
docker rm open-webui
#docker volume rm open-webui
docker rmi de5d58daf875 
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
