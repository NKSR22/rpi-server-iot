#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

STAMP=$(date +%Y%m%d-%H%M%S)
DEST="backup-${STAMP}"

mkdir -p "$DEST"
cp -r docker/mosquitto/data "$DEST/mosquitto-data"
cp -r docker/nodered/data "$DEST/nodered-data"
cp -r docker/influxdb/data "$DEST/influxdb-data"
cp -r docker/influxdb/config "$DEST/influxdb-config"
cp -r docker/grafana/data "$DEST/grafana-data"

echo "Backup created in $DEST"
