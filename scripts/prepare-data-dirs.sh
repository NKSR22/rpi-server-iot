#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

ensure_dir() {
  dir_path="$1"

  if [ ! -d "$dir_path" ]; then
    mkdir -p "$dir_path"
  fi
}

fix_grafana_permissions() {
  grafana_dir="$PROJECT_ROOT/docker/grafana/data"

  ensure_dir "$grafana_dir"

  if command -v sudo >/dev/null 2>&1; then
    sudo chown -R 472:472 "$grafana_dir"
    sudo chmod -R u+rwX,g+rX,o-rwx "$grafana_dir"
  else
    chown -R 472:472 "$grafana_dir"
    chmod -R u+rwX,g+rX,o-rwx "$grafana_dir"
  fi
}

ensure_dir "$PROJECT_ROOT/docker/mosquitto/data"
ensure_dir "$PROJECT_ROOT/docker/mosquitto/log"
ensure_dir "$PROJECT_ROOT/docker/nodered/data"
ensure_dir "$PROJECT_ROOT/docker/influxdb/data"
ensure_dir "$PROJECT_ROOT/docker/influxdb/config"
ensure_dir "$PROJECT_ROOT/docker/grafana/data"

fix_grafana_permissions

echo "Prepared data directories and fixed Grafana write permissions."
