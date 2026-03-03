#!/bin/bash

# 1. Create a shared network
docker network create openwebui-network

# 2. Connect both containers to it
docker network connect openwebui-network litellm
docker network connect openwebui-network open-webui
