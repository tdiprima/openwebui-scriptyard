#!/bin/bash

# Ubuntu 24 Security Setup Script
# Run with: sudo bash secure-setup.sh

set -e

echo "🔄 Updating everything..."
apt update && apt upgrade -y
apt autoremove -y

echo "🔥 Setting up UFW firewall..."
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 3000/tcp comment 'Open WebUI'
ufw allow 5858/tcp comment 'n8n'
ufw --force enable

echo "🛡️ Installing security tools..."
apt install fail2ban unattended-upgrades -y

echo "⚙️ Configuring automatic security updates..."
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "🚫 Configuring fail2ban for SSH..."
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo "🔒 Hardening SSH..."
# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply security settings (keeping password auth for now - you can disable later)
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax.*/ClientAliveCountMax 2/' /etc/ssh/sshd_config

systemctl restart ssh

echo ""
echo "✅ DONE! Here's your setup:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
ufw status
echo ""
echo "fail2ban status:"
fail2ban-client status sshd 2>/dev/null || echo "  (will activate on next SSH attempt)"
echo ""
echo "🎉 Your VM is now secured!"
