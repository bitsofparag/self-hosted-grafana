#!/bin/bash
set -eou pipefail
export DEBIAN_FRONTEND=noninteractive
export OS_NAME=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
export OS_CODE=$(lsb_release -cs | tr '[:upper:]' '[:lower:]')
export DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-1.29.2}

apt_install='apt-get install -y --no-install-recommends'

echo ">>>>> Add GPG key for Docker repo..."
curl -fsSL https://download.docker.com/linux/${OS_NAME}/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Add docker repository to APT sources..."
echo \
    add-apt-repository "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${OS_NAME} ${OS_CODE} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ">>>>> Install docker..."
apt-get update
apt-cache policy docker-ce
$apt_install docker-ce docker-ce-cli containerd.io

echo ">>>>> Check docker status..."
docker --version
systemctl status docker --no-pager

echo ">>>>> Install docker-compose..."
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
