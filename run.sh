#!/usr/bin/env bash
set -euo pipefail

# --- Ajustes ---
export TZ=America/Sao_Paulo                     # garante horário local desejado
APP_DIR="/opt/cdc-validation"
BIN="$APP_DIR/inthub-cdc-data-validation-linux-amd64"
CFG="$APP_DIR/config.yaml"
LOG_DIR="$APP_DIR/logs"
LOCK="$APP_DIR/run.lock"

mkdir -p "$LOG_DIR"
cd "$APP_DIR"

# Nome do arquivo de log (ex: 2025-09-30_09-00-00.log)
STAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/${STAMP}.log"

# Evita concorrência (se uma execução anterior ainda estiver rodando)
exec 9>"$LOCK"
if ! flock -n 9; then
  msg="[$(date +'%F %T')] Já existe uma execução em andamento. Saindo."
  echo "$msg"                                # vai para cron.log (via redirecionamento do crontab)
  echo "$msg" >> "$LOG_DIR/cron-wrapper.log" # registro dedicado de bloqueio
  exit 1
fi

# Execução com flush por linha + timestamps e gravação em arquivo
stdbuf -oL -eL "$BIN" -c "$CFG" 2>&1 \
| awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' \
| tee -a "$LOG_FILE"
