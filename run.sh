#!/usr/bin/env bash
set -Eeuo pipefail

# ===== Configurações =====
export TZ=America/Sao_Paulo
APP_DIR="/opt/cdc-validation"
BIN="$APP_DIR/inthub-cdc-data-validation-linux-amd64"
CFG="$APP_DIR/config.yaml"
LOG_DIR="$APP_DIR/logs"
LOCK="$APP_DIR/run.lock"

# ===== Preparação =====
mkdir -p "$LOG_DIR"
cd "$APP_DIR"

# Nome do log com data+hora
STAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/${STAMP}.log"

# ===== Evita concorrência =====
exec 9>"$LOCK"
flock -n 9 || { echo "[$(date +'%F %T')] Já existe uma execução em andamento. Saindo." >> "$LOG_DIR/cron-wrapper.log"; exit 1; }

# ===== Execução =====
stdbuf -oL -eL "$BIN" -c "$CFG" 2>&1 \
| awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' \
| tee -a "$LOG_FILE"
