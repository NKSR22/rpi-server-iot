#!/usr/bin/env bash
set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

MQTT_USER="$1"
MQTT_PASSWORD="$2"
MQTT_CONFIG_DIR="$PROJECT_ROOT/docker/mosquitto/config"
MQTT_CONFIG_FILE="$MQTT_CONFIG_DIR/mosquitto.conf"
MQTT_PASSWD_FILE="$MQTT_CONFIG_DIR/passwd"
BACKUP_FILE="$MQTT_CONFIG_DIR/mosquitto.conf.bak"

cd "$PROJECT_ROOT"

mkdir -p "$MQTT_CONFIG_DIR"

if [ ! -f "$MQTT_CONFIG_FILE" ]; then
  echo "Mosquitto config not found: $MQTT_CONFIG_FILE"
  exit 1
fi

cp "$MQTT_CONFIG_FILE" "$BACKUP_FILE"

docker run --rm \
  -v "$MQTT_CONFIG_DIR:/mosquitto/config" \
  eclipse-mosquitto:2 \
  mosquitto_passwd -b /mosquitto/config/passwd "$MQTT_USER" "$MQTT_PASSWORD"

if rg -q '^password_file ' "$MQTT_CONFIG_FILE"; then
  :
else
  printf '\npassword_file /mosquitto/config/passwd\n' >> "$MQTT_CONFIG_FILE"
fi

if rg -q '^allow_anonymous ' "$MQTT_CONFIG_FILE"; then
  perl -0pi -e 's/^allow_anonymous .*/allow_anonymous false/m' "$MQTT_CONFIG_FILE"
else
  printf 'allow_anonymous false\n' >> "$MQTT_CONFIG_FILE"
fi

echo "MQTT authentication enabled."
echo "Config backup: $BACKUP_FILE"
echo "Restart Mosquitto with: docker compose restart mosquitto"
