#!/bin/bash

sudo ufw disable
sudo ufw enable
sudo systemctl restart docker
docker restart open-webui

