#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"

cd "$PROJECT_ROOT"

echo "======================================"
echo " HCR Monitoring Deployment"
echo "======================================"

if [ ! -f ".env.monitoring" ]; then
    echo "[FAIL] .env.monitoring missing"
    exit 1
fi

docker compose \
    --env-file .env.monitoring \
    -f compose/compose.monitoring.yaml \
    config >/dev/null

echo "[OK] Monitoring Compose configuration"

docker compose \
    --env-file .env.monitoring \
    -f compose/compose.monitoring.yaml \
    up -d

echo "[OK] Monitoring stack started"
