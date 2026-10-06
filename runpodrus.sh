#!/usr/bin/env bash
# Настройка UTF-8 локали, чтобы русские буквы отображались в терминале.
# Можно запускать повторно: уже сделанные шаги пропускаются.
# Использование: sudo bash setup-ru-locale.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите от root: sudo bash $0" >&2
  exit 1
fi

DEFAULT_LOCALE="${DEFAULT_LOCALE:-en_US.UTF-8}"   # язык сообщений системы; для русского интерфейса: DEFAULT_LOCALE=ru_RU.UTF-8
TARGET_HOME="${SUDO_USER:+$(getent passwd "$SUDO_USER" | cut -d: -f6)}"
TARGET_HOME="${TARGET_HOME:-$HOME}"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

# 1. Пакеты и генерация локалей
if command -v apt-get >/dev/null; then
  if ! dpkg -s locales >/dev/null 2>&1; then
    log "Устанавливаю пакет locales"
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq locales
  fi
  for loc in en_US ru_RU; do
    if grep -q "^# *${loc}.UTF-8 UTF-8" /etc/locale.gen; then
      sed -i -E "s/^# *(${loc}.UTF-8 UTF-8)/\1/" /etc/locale.gen
    elif ! grep -q "^${loc}.UTF-8 UTF-8" /etc/locale.gen; then
      echo "${loc}.UTF-8 UTF-8" >> /etc/locale.gen
    fi
  done
  log "Генерирую локали"
  locale-gen
  update-locale LANG="$DEFAULT_LOCALE" LC_CTYPE="$DEFAULT_LOCALE"
elif command -v dnf >/dev/null || command -v yum >/dev/null; then
  PM=$(command -v dnf || command -v yum)
  log "Устанавливаю языковые пакеты"
  "$PM" install -y -q glibc-langpack-en glibc-langpack-ru 2>/dev/null || "$PM" install -y -q glibc-common
  command -v localectl >/dev/null && localectl set-locale LANG="$DEFAULT_LOCALE" 2>/dev/null || true
  echo "LANG=$DEFAULT_LOCALE" > /etc/locale.conf
else
  echo "Неизвестный пакетный менеджер — поддерживаются apt, dnf, yum" >&2
  exit 1
fi

# 2. Переменные окружения: для всех пользователей и в ~/.bashrc
#    (в контейнерах /etc/default/locale часто не читается)
cat > /etc/profile.d/utf8-locale.sh <<EOF
export LANG=$DEFAULT_LOCALE
export LC_ALL=$DEFAULT_LOCALE
EOF
BASHRC="$TARGET_HOME/.bashrc"
touch "$BASHRC"
if ! grep -q '# UTF-8 locale (Cyrillic support)' "$BASHRC"; then
  log "Добавляю локаль в $BASHRC"
  cat >> "$BASHRC" <<EOF

# UTF-8 locale (Cyrillic support)
export LANG=$DEFAULT_LOCALE
export LC_ALL=$DEFAULT_LOCALE
EOF
fi

# 3. screen и tmux
SCREENRC="$TARGET_HOME/.screenrc"
touch "$SCREENRC"
grep -q '^defutf8' "$SCREENRC" || printf 'defutf8 on\nutf8 on on\n' >> "$SCREENRC"
if command -v tmux >/dev/null; then
  TMUXCONF="$TARGET_HOME/.tmux.conf"
  touch "$TMUXCONF"
  grep -q 'default-terminal' "$TMUXCONF" || echo 'set -g default-terminal "screen-256color"' >> "$TMUXCONF"
fi
[ -n "${SUDO_USER:-}" ] && chown "$SUDO_USER": "$BASHRC" "$SCREENRC" "${TMUXCONF:-$BASHRC}"

# 4. Проверка
log "Доступные локали:"
locale -a | grep -iE 'utf-?8'
LANG=$DEFAULT_LOCALE LC_ALL=$DEFAULT_LOCALE bash -c 'echo "Проверка: съешь ещё этих мягких французских булок"'
log "Готово. Перезайдите по SSH (или выполните: source ~/.bashrc)."
log "Старые сессии screen не подхватят настройку — откройте новую."
