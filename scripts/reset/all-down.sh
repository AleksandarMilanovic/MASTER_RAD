#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"

cd "$PROJECT_ROOT"

echo
echo "================================================"
echo "       HYBRID CYBER RANGE SHUTDOWN"
echo "================================================"
echo

echo "[1/4] Stopping monitoring..."
./scripts/reset/monitoring-down.sh || true

echo
echo "[2/4] Stopping CALDERA..."
./scripts/reset/caldera-down.sh || true

echo
echo "[3/4] Stopping TheHive..."
./scripts/reset/thehive-down.sh || true

echo
echo "[4/4] Stopping Wazuh..."
./scripts/reset/wazuh-down.sh || true

echo
echo "================================================"
echo " Hybrid Cyber Range stopped"
echo " Persistent data and Docker networks preserved"
echo "================================================"
