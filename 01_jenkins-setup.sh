#!/bin/bash

set -e

echo "======================================"
echo " Jenkins LTS Installation"
echo "======================================"

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "sudo ./install_jenkins.sh"
    exit 1
fi

echo ""
echo "[1/7] Updating system packages..."
apt update
apt upgrade -y

echo ""
echo "[2/7] Installing prerequisites..."
apt install -y \
    wget \
    curl \
    gnupg \
    ca-certificates \
    fontconfig

echo ""
echo "[3/7] Installing Java 21..."

apt install -y openjdk-21-jre

echo ""
echo "Java version:"
java -version

echo ""
echo "[4/7] Configuring Jenkins repository..."

# Remove old Jenkins repository/key configuration
rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /etc/apt/keyrings/jenkins-keyring.asc

# Create keyrings directory
mkdir -p /etc/apt/keyrings

# Download current Jenkins repository signing key
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add Jenkins LTS repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

echo ""
echo "[5/7] Updating package lists..."

apt update

echo ""
echo "[6/7] Installing Jenkins..."

apt install -y jenkins

echo ""
echo "[7/7] Enabling and starting Jenkins..."

systemctl enable jenkins
systemctl start jenkins

echo ""
echo "======================================"
echo " Jenkins Installation Complete"
echo "======================================"

echo ""
echo "Jenkins service status:"
systemctl --no-pager status jenkins

echo ""
echo "======================================"
echo " Jenkins Initial Admin Password"
echo "======================================"

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Initial password file not found yet."
    echo "Check later with:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "======================================"
echo " Jenkins URL"
echo "======================================"

IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "http://${IP_ADDRESS}:8080"
echo ""
echo "Installation finished successfully."
