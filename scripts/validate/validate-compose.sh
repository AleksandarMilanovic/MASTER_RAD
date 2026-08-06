#!/usr/bin/env bash
set -Eeuo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$project_root"

if [[ ! -f .env ]]; then
  echo "[INFO] .env ne postoji; koristi se .env.example za validaciju"
  cp .env.example .env.validation
  trap 'rm -f .env.validation' EXIT
  docker compose --env-file .env.validation -f compose/compose.yaml config >/dev/null
else
  docker compose --env-file .env -f compose/compose.yaml config >/dev/null
fi

echo "[OK] Compose konfiguracija je sintaksno ispravna"
