#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

set -e

#wget -O setup_server1.sh https://raw.githubusercontent.com/tarabukinivan/haqq_zamena_bin/refs/heads/main/setup_server1.sh && chmod a+x setup_server1.sh && ./setup_server1.sh 

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

echo "🔄 Rebooting..."

reboot
