#!/usr/bin/env bash
set -eu

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "[OK] $1"
  else
    echo "[MISSING] $1"
    return 1
  fi
}

status=0

for cmd in git curl wget gpg nano nvim jq rg rsync tree unzip zip ip ping ss lsof mosquitto_pub mosquitto_sub docker; do
  if ! check_cmd "$cmd"; then
    status=1
  fi
done

if docker compose version >/dev/null 2>&1; then
  echo "[OK] docker compose"
else
  echo "[MISSING] docker compose"
  status=1
fi

if systemctl is-enabled avahi-daemon >/dev/null 2>&1; then
  echo "[OK] avahi-daemon enabled"
else
  echo "[WARN] avahi-daemon not enabled"
fi

exit "$status"
