#!/bin/bash
# =============================================================================
# Установка зависимостей для SFT + GRPO обучения на Ubuntu 22.04 + A100
# Запускать от root или с sudo
# Использование: bash install.sh
# =============================================================================

set -e  # Остановиться при любой ошибке

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo "=============================================="
echo " SFT + GRPO Training Environment Setup"
echo " Ubuntu 22.04 + A100"
echo "=============================================="

# =============================================================================
# 1. СИСТЕМНЫЕ ПАКЕТЫ
# =============================================================================
log "Обновление системы..."
apt-get update -q
apt-get install -y -q \
    build-essential \
    git \
    git-lfs \
    curl \
    wget \
    vim \
    tmux \
    htop \
    nvtop \
    unzip \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    ninja-build \
    libssl-dev \
    libffi-dev \
    libaio-dev \
    2>/dev/null

git lfs install --skip-smudge 2>/dev/null || true
log "Системные пакеты установлены"

# =============================================================================
# 2. ПРОВЕРКА CUDA
# =============================================================================
log "Проверка CUDA..."
if ! command -v nvidia-smi &>/dev/null; then
    fail "nvidia-smi не найден. Убедись что GPU драйвер установлен."
fi

nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')
log "CUDA Version: ${CUDA_VERSION}"

# =============================================================================
# 3. PYTHON ВИРТУАЛЬНОЕ ОКРУЖЕНИЕ
# =============================================================================
VENV_DIR="/opt/train_env"

if [ -d "$VENV_DIR" ]; then
    warn "Виртуальное окружение уже существует: $VENV_DIR"
    warn "Удаляю и пересоздаю..."
    rm -rf "$VENV_DIR"
fi

log "Создание виртуального окружения: $VENV_DIR"
python3.10 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Обновить pip
pip install --upgrade pip setuptools wheel -q
log "Python окружение готово: $(python --version)"

# =============================================================================
# 4. PYTORCH + CUDA
# =============================================================================
log "Установка PyTorch 2.4 + CUDA 12.1..."
pip install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 \
    --index-url https://download.pytorch.org/whl/cu121 -q

# Проверка
python -c "
import torch
print(f'  PyTorch: {torch.__version__}')
print(f'  CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
    print(f'  VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')
    print(f'  BF16 support: {torch.cuda.is_bf16_supported()}')
"
log "PyTorch установлен"

# =============================================================================
# 5. FLASH ATTENTION 2
# =============================================================================
log "Установка Flash Attention 2 (компилируется ~5-10 минут)..."
pip install flash-attn==2.6.3 --no-build-isolation -q
log "Flash Attention 2 установлен"

# =============================================================================
# 6. ОСНОВНЫЕ ML БИБЛИОТЕКИ
# =============================================================================
log "Установка transformers / trl / peft / datasets..."

pip install -q \
    "transformers==4.45.0" \
    "trl==0.11.4" \
    "peft==0.13.0" \
    "datasets==3.0.1" \
    "accelerate==0.34.2" \
    "bitsandbytes==0.44.0"

log "ML библиотеки установлены"

# =============================================================================
# 7. DEEPSPEED (опционально, для multi-GPU или ZeRO)
# =============================================================================
log "Установка DeepSpeed..."
pip install deepspeed==0.15.1 -q
log "DeepSpeed установлен"

# =============================================================================
# 8. ВСПОМОГАТЕЛЬНЫЕ БИБЛИОТЕКИ
# =============================================================================
log "Установка вспомогательных пакетов..."

pip install -q \
    wandb \
    huggingface_hub \
    sentencepiece \
    tokenizers \
    scipy \
    numpy \
    pandas \
    tqdm \
    rich \
    psutil \
    py-cpuinfo \
    einops \
    packaging \
    ninja

log "Вспомогательные пакеты установлены"

# =============================================================================
# 9. AFFINE SDK
# =============================================================================
log "Установка Affine SDK..."
pip install affine -q 2>/dev/null || warn "affine не найден в PyPI — установи вручную из репозитория"

# =============================================================================
# 10. ВЕРСИИ — ФИНАЛЬНАЯ ПРОВЕРКА
# =============================================================================
echo ""
echo "=============================================="
echo " ФИНАЛЬНАЯ ПРОВЕРКА ВЕРСИЙ"
echo "=============================================="

python -c "
import sys
print(f'Python:        {sys.version.split()[0]}')

import torch
print(f'PyTorch:       {torch.__version__}')
print(f'CUDA:          {torch.version.cuda}')
print(f'GPU available: {torch.cuda.is_available()}')

import transformers
print(f'Transformers:  {transformers.__version__}')

import trl
print(f'TRL:           {trl.__version__}')

import peft
print(f'PEFT:          {peft.__version__}')

import datasets
print(f'Datasets:      {datasets.__version__}')

import accelerate
print(f'Accelerate:    {accelerate.__version__}')

import bitsandbytes as bnb
print(f'BitsAndBytes:  {bnb.__version__}')

try:
    import flash_attn
    print(f'FlashAttn:     {flash_attn.__version__}')
except ImportError:
    print('FlashAttn:     НЕ УСТАНОВЛЕН')

try:
    import deepspeed
    print(f'DeepSpeed:     {deepspeed.__version__}')
except ImportError:
    print('DeepSpeed:     НЕ УСТАНОВЛЕН')

try:
    import affine
    print(f'Affine SDK:    OK')
except ImportError:
    print('Affine SDK:    НЕ УСТАНОВЛЕН (установи вручную)')

import wandb
print(f'WandB:         {wandb.__version__}')
"

# =============================================================================
# 11. НАСТРОЙКА ПЕРЕМЕННЫХ ОКРУЖЕНИЯ
# =============================================================================
ACTIVATE_SCRIPT="$VENV_DIR/bin/activate"

# Добавить полезные env vars в activate скрипт
cat >> "$ACTIVATE_SCRIPT" << 'EOF'

# ── Training optimizations ────────────────────────────────────
export TOKENIZERS_PARALLELISM=false
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export CUDA_VISIBLE_DEVICES=0
# Для Flash Attention
export FLASH_ATTENTION_SKIP_CUDA_BUILD=0
# HuggingFace cache
export HF_HOME=/root/.cache/huggingface
export TRANSFORMERS_CACHE=/root/.cache/huggingface/transformers
EOF

log "Переменные окружения добавлены в $ACTIVATE_SCRIPT"

# =============================================================================
# 12. ИНСТРУКЦИЯ ЗАПУСКА
# =============================================================================
echo ""
echo "=============================================="
echo " ГОТОВО! Как запускать:"
echo "=============================================="
echo ""
echo "  # Активировать окружение:"
echo "  source $VENV_DIR/bin/activate"
echo ""
echo "  # Логин в WandB:"
echo "  wandb login"
echo ""
echo "  # Логин в HuggingFace:"
echo "  huggingface-cli login"
echo ""
echo "  # Запуск SFT (рекомендуется в tmux):"
echo "  tmux new -s sft"
echo "  python sft_train.py"
echo ""
echo "  # После SFT — запуск GRPO:"
echo "  python grpo_train.py"
echo ""
echo "  # Мониторинг GPU:"
echo "  watch -n 1 nvidia-smi"
echo ""
