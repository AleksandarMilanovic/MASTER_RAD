#!/usr/bin/env bash
set -Eeuo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$project_root"

if [[ ! -f .env ]]; then
  echo "[FAIL] Kreiraj .env na osnovu .env.example"
  exit 1
fi

docker compose --env-file .env -f compose/compose.yaml --profile core up -d
docker compose --env-file .env -f compose/compose.yaml ps
