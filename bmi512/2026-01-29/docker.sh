# Add Docker's repo
curl -fsSL https://get.docker.com | sudo sh

# Let yourself run docker without sudo
sudo usermod -aG docker $USER

# LOG OUT AND BACK IN (or reboot)

# Test it worked
# docker --version
