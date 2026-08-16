#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"

echo "======================================"
echo " HCR Monitoring Shutdown"
echo "======================================"

cd "$PROJECT_ROOT"

docker compose \
    --env-file .env.monitoring \
    -f compose/compose.monitoring.yaml \
    down

echo "[OK] Monitoring stack stopped"
