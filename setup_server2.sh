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
