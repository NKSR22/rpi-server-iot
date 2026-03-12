#!/usr/bin/env bash
set -eu

STAMP=$(date +%Y%m%d-%H%M%S)
DEST="backup-${STAMP}"

mkdir -p "$DEST"
cp -r docker/mosquitto/data "$DEST/mosquitto-data"
cp -r docker/nodered/data "$DEST/nodered-data"
cp -r docker/influxdb/data "$DEST/influxdb-data"
cp -r docker/influxdb/config "$DEST/influxdb-config"
cp -r docker/grafana/data "$DEST/grafana-data"

echo "Backup created in $DEST"
