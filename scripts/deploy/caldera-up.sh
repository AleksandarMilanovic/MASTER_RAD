#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"
CALDERA_DIR="${PROJECT_ROOT}/security-platform/caldera"
CALDERA_PYTHON="${CALDERA_DIR}/.venv/bin/python"
SERVICE="hcr-caldera"

echo "======================================"
echo " HCR CALDERA Deployment"
echo "======================================"

if [[ ! -d "$CALDERA_DIR" ]]; then
    echo "[FAIL] CALDERA directory not found:"
    echo "$CALDERA_DIR"
    exit 1
fi

if [[ ! -x "$CALDERA_PYTHON" ]]; then
    echo "[FAIL] CALDERA virtual environment is missing"
    echo "[INFO] Expected interpreter:"
    echo "$CALDERA_PYTHON"
    exit 1
fi

if ! "$CALDERA_PYTHON" \
    -c "import aiohttp_apispec" \
    >/dev/null 2>&1
then
    echo "[FAIL] CALDERA Python dependencies are incomplete"
    exit 1
fi

if ! systemctl cat "${SERVICE}.service" \
    >/dev/null 2>&1
then
    echo "[FAIL] ${SERVICE}.service is not installed"
    exit 1
fi

if systemctl is-active \
    --quiet "$SERVICE"
then
    echo "[INFO] CALDERA is already running"
else
    echo "[INFO] Starting CALDERA..."
    sudo systemctl start "$SERVICE"
fi

echo "[INFO] Waiting for CALDERA HTTP service..."

for i in $(seq 1 60); do

    HTTP_CODE="$(
        curl \
            --silent \
            --output /dev/null \
            --write-out '%{http_code}' \
            --max-time 3 \
            http://127.0.0.1:8888 \
            || true
    )"

    if [[ "$HTTP_CODE" =~ ^(200|302|401)$ ]]; then
        echo "[OK] CALDERA reachable: HTTP ${HTTP_CODE}"
        exit 0
    fi

    sleep 2
done

echo "[FAIL] CALDERA did not become reachable"

sudo systemctl status \
    "$SERVICE" \
    --no-pager || true

echo
echo "=== CALDERA logs ==="

sudo journalctl \
    -u "$SERVICE" \
    -n 50 \
    --no-pager || true

exit 1