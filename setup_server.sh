#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

set -e

#wget -O setup_server.sh https://raw.githubusercontent.com/tarabukinivan/mergekit_conf/refs/heads/main/setup_server.sh?token=GHSAT0AAAAAADW2VZVXTTYJLVEOX3XHQV3Q2OH5QCQ && chmod a+x setup_server.sh && ./setup_server.sh
set -e  # остановка при ошибке

echo "🔥 START SERVER SETUP"

# =========================
# SYSTEM UPDATE
# =========================
apt update -y && apt upgrade -y

# =========================
# REMOVE NVIDIA / CUDA
# =========================
echo "🧹 Removing old NVIDIA/CUDA..."

systemctl stop nvidia-persistenced || true

apt-get purge -y 'nvidia*' || true
apt-get purge -y 'cuda*' || true

rm -rf /usr/local/cuda* || true
rm -rf /usr/lib/nvidia-* || true

apt autoremove -y
apt purge -y 'nvidia-*' 'cuda-*' 'libnvidia-*' || true
apt autoremove -y
apt autoclean

rm -rf /etc/apt/sources.list.d/cuda* || true
rm -f /etc/apt/preferences.d/cuda* || true
rm -f /var/lib/dpkg/info/libnvidia* || true

apt update -y
apt upgrade -y

dpkg --configure -a
apt --fix-broken install -y

# =========================
# INSTALL CUDA 13.2
# =========================
echo "⚡ Installing CUDA 13.2..."

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

wget https://developer.download.nvidia.com/compute/cuda/13.2.0/local_installers/cuda-repo-ubuntu2204-13-2-local_13.2.0-595.45.04-1_amd64.deb
dpkg -i cuda-repo-ubuntu2204-13-2-local_13.2.0-595.45.04-1_amd64.deb

cp /var/cuda-repo-ubuntu2204-13-2-local/cuda-*-keyring.gpg /usr/share/keyrings/

apt-get update
apt-get install -y cuda-toolkit-13-2
apt-get install -y cuda-drivers

# =========================
# NVIDIA CONTAINER TOOLKIT
# =========================
echo "🐳 Installing NVIDIA Container Toolkit..."

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update
apt-get install -y nvidia-container-toolkit

# =========================
# DOCKER SETUP
# =========================
echo "⚙️ Configuring Docker..."

nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# =========================
# PULL IMAGE
# =========================
echo "📦 Pulling Docker image..."

docker pull lmsysorg/sglang:nightly-dev-cu13-20260321-94194537

# =========================
# PYTHON + UV
# =========================
echo "🐍 Installing Python & uv..."

apt install -y python3.10-venv git curl

curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# =========================
# CLONE REPO
# =========================
echo "📂 Cloning affine-cortex..."

cd /root
git clone https://github.com/AffineFoundation/affine-cortex || true

cd affine-cortex

# =========================
# VENV + INSTALL
# =========================
echo "📦 Installing project..."

~/.local/bin/uv venv
source .venv/bin/activate

~/.local/bin/uv pip install -e .

# =========================
# CREATE .env
# =========================
echo "📝 Creating .env..."

cat > /root/affine-cortex/.env <<EOF
SUBTENSOR_ENDPOINT="finney"
SUBTENSOR_FALLBACK="wss://lite.sub.latent.to:443"

CHUTE_USER=tarab
CHUTES_API_KEY=

HF_TOKEN=
DOCKER_HUB_USERNAME=tarabukinivan
DOCKER_HUB_TOKEN=
COINGECKO_API_KEY=
AMAP_MAPS_API_KEY=
EOF

echo "✅ .env created"

# =========================
# DONE
# =========================
echo "🎉 SETUP COMPLETE"
echo "🔄 Rebooting..."

reboot
