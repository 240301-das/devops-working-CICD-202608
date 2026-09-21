#!/bin/bash

set -e

echo "=========================================="
echo "     Docker Complete Installation"
echo "=========================================="

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo:"
    echo "sudo ./install_docker.sh"
    exit 1
fi

echo ""
echo "[1/8] Removing old Docker packages..."

apt-get remove -y \
    docker.io \
    docker-doc \
    docker-compose \
    docker-compose-v2 \
    podman-docker \
    containerd \
    runc 2>/dev/null || true

echo ""
echo "[2/8] Updating package lists..."

apt-get update

echo ""
echo "[3/8] Installing prerequisites..."

apt-get install -y \
    ca-certificates \
    curl \
    gnupg

echo ""
echo "[4/8] Adding Docker's official GPG key..."

install -m 0755 -d /etc/apt/keyrings

rm -f /etc/apt/keyrings/docker.asc

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo ""
echo "[5/8] Adding Docker repository..."

# Detect Ubuntu architecture and release
ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

echo ""
echo "Docker repository:"
cat /etc/apt/sources.list.d/docker.list

echo ""
echo "[6/8] Installing Docker Engine..."

apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo ""
echo "[7/8] Enabling and starting Docker..."

systemctl enable docker
systemctl start docker

echo ""
echo "[8/8] Configuring Docker for the current user..."

# Find the user who invoked sudo
REAL_USER="${SUDO_USER:-}"

if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then

    usermod -aG docker "$REAL_USER"

    echo ""
    echo "Added $REAL_USER to the docker group."

else
    echo ""
    echo "No non-root user detected."
    echo "Add your user manually with:"
    echo "sudo usermod -aG docker <username>"
fi

echo ""
echo "=========================================="
echo "       Docker Installation Complete"
echo "=========================================="

echo ""
echo "Docker version:"
docker --version

echo ""
echo "Docker Compose version:"
docker compose version

echo ""
echo "Docker service status:"
systemctl --no-pager --full status docker

echo ""
echo "=========================================="
echo "       Test Docker Installation"
echo "=========================================="

docker run --rm hello-world

echo ""
echo "=========================================="
echo "IMPORTANT"
echo "=========================================="

if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then
    echo "Log out and log back in for the docker group change to take effect."
    echo ""
    echo "Then test:"
    echo "docker run hello-world"
fi

echo ""
echo "Docker installation completed successfully."
