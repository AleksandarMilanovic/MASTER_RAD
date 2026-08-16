#!/usr/bin/env bash
set -Eeuo pipefail

SERVICE="hcr-caldera"

echo "======================================"
echo " HCR CALDERA Shutdown"
echo "======================================"

if systemctl is-active \
    --quiet "$SERVICE"
then

    echo "[INFO] Stopping CALDERA..."

    sudo systemctl stop "$SERVICE"

    echo "[OK] CALDERA stopped"

else
    echo "[INFO] CALDERA already stopped"
fi