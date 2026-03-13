#!/usr/bin/env bash
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <backup-directory>"
  exit 1
fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$1"

cd "$PROJECT_ROOT"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Backup directory not found: $SOURCE_DIR"
  exit 1
fi

STAMP=$(date +%Y%m%d-%H%M%S)
SAFETY_DIR="pre-restore-${STAMP}"

mkdir -p "$SAFETY_DIR"
cp .env "$SAFETY_DIR/.env" 2>/dev/null || true
cp compose.yaml "$SAFETY_DIR/compose.yaml"
cp -r docker/mosquitto/config "$SAFETY_DIR/mosquitto-config"
cp -r docker/mosquitto/data "$SAFETY_DIR/mosquitto-data"
cp -r docker/mosquitto/log "$SAFETY_DIR/mosquitto-log"
cp -r docker/nodered/data "$SAFETY_DIR/nodered-data"
cp -r docker/influxdb/data "$SAFETY_DIR/influxdb-data"
cp -r docker/influxdb/config "$SAFETY_DIR/influxdb-config"
cp -r docker/grafana/provisioning "$SAFETY_DIR/grafana-provisioning"
cp -r docker/grafana/data "$SAFETY_DIR/grafana-data"

cp "$SOURCE_DIR/.env" .env 2>/dev/null || true
cp "$SOURCE_DIR/compose.yaml" compose.yaml 2>/dev/null || true
rsync -a --delete "$SOURCE_DIR/mosquitto-config/" docker/mosquitto/config/
rsync -a --delete "$SOURCE_DIR/mosquitto-data/" docker/mosquitto/data/
rsync -a --delete "$SOURCE_DIR/mosquitto-log/" docker/mosquitto/log/ 2>/dev/null || true
rsync -a --delete "$SOURCE_DIR/nodered-data/" docker/nodered/data/
rsync -a --delete "$SOURCE_DIR/influxdb-data/" docker/influxdb/data/
rsync -a --delete "$SOURCE_DIR/influxdb-config/" docker/influxdb/config/
rsync -a --delete "$SOURCE_DIR/grafana-provisioning/" docker/grafana/provisioning/ 2>/dev/null || true
rsync -a --delete "$SOURCE_DIR/grafana-data/" docker/grafana/data/

echo "Restore completed from $SOURCE_DIR"
echo "Current state backup stored in $SAFETY_DIR"
