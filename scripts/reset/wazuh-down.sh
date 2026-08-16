#!/usr/bin/env bash
set -Eeuo pipefail

WAZUH_DIR="/opt/hybrid-cyber-range/security-platform/wazuh"

echo "======================================"
echo " HCR Wazuh Shutdown"
echo "======================================"

cd "$WAZUH_DIR"

docker compose down

echo "[OK] Wazuh stack stopped"
