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

sudo reboot
