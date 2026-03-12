#!/usr/bin/env bash
set -eu

if [ ! -f .env ]; then
  echo ".env not found. Copy .env.example to .env first."
  exit 1
fi

docker compose up -d
docker compose ps
