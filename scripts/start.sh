#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

if [ ! -f .env ]; then
  echo ".env not found. Copy .env.example to .env first."
  exit 1
fi

if [ -x "$SCRIPT_DIR/prepare-data-dirs.sh" ]; then
  "$SCRIPT_DIR/prepare-data-dirs.sh"
fi

docker compose up -d
docker compose ps
