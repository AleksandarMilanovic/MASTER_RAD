#!/usr/bin/env bash
set -Eeuo pipefail

THEHIVE_DIR="/opt/hybrid-cyber-range/security-platform/thehive-vendor/prod1-thehive"

echo "======================================"
echo " HCR TheHive Shutdown"
echo "======================================"

if [[ ! -d "$THEHIVE_DIR" ]]; then
    echo "[INFO] TheHive directory not found; nothing to stop"
    exit 0
fi

cd "$THEHIVE_DIR"

docker compose down

echo "[OK] TheHive stack stopped"
