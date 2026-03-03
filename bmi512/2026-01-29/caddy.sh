# 1. Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy -y

# 2. Create Caddy config
sudo tee /etc/caddy/Caddyfile > /dev/null <<EOF
bmi512-webllm.eastus2.cloudapp.azure.com {
    reverse_proxy localhost:3000
}
EOF

# 3. Open port 443 in UFW
sudo ufw allow 443/tcp comment 'HTTPS'

# 4. Restart Caddy
sudo systemctl restart caddy

