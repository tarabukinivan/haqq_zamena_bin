#!/bin/bash

# Проверка наличия параметра порта
if [ -z "$1" ]; then
    echo "Ошибка: Укажите порт как параметр"
    echo "Пример: $0 15371"
    exit 1
fi

PORT=$1

# Проверка, что порт - число
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: Порт должен быть числом"
    exit 1
fi

echo "=== Обновление пакетов ==="
apt update -y

echo "=== Установка необходимых пакетов ==="
apt install tmux nano sudo wget -y

echo "=== Клонирование репозитория ==="
git clone https://github.com/kingcharlezz/qwen36-current-profile-endpoint.git /root/qwen36-current-profile-endpoint

echo "=== Установка vLLM ==="
cd /root/qwen36-current-profile-endpoint
scripts/install_vllm023_pr.sh

echo "=== Применение патчей vLLM ==="
scripts/apply_vllm_patches.sh

echo "=== Создание директории и API ключа ==="
install -d -m 700 /root/out/qwen36_current_profile
openssl rand -hex 24 > /root/out/qwen36_current_profile/api_key.txt
chmod 600 /root/out/qwen36_current_profile/api_key.txt

echo "=== Запуск сервиса на порту $PORT ==="
export DET_PORT=$PORT
scripts/start_qwen36_current_profile.sh

echo ""
echo "=== ИНФОРМАЦИЯ О ЗАПУСКЕ ==="
echo "API ключ:"
cat /root/out/qwen36_current_profile/api_key.txt
echo ""
echo "Порт: $PORT"
echo ""
echo "Для просмотра логов выполните:"
echo "tail -f /root/out/qwen36_current_profile/server.log"
