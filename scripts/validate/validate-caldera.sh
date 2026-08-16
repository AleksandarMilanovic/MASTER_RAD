#!/usr/bin/env bash
set -Eeuo pipefail

CALDERA_DIR="/opt/hybrid-cyber-range/security-platform/caldera"
CALDERA_PYTHON="${CALDERA_DIR}/.venv/bin/python"
SERVICE="hcr-caldera"

echo "=== CALDERA Validation ==="

if [[ ! -x "$CALDERA_PYTHON" ]]; then
    echo "[FAIL] CALDERA virtual environment missing"
    exit 1
fi

echo "[OK] CALDERA virtual environment"

if ! "$CALDERA_PYTHON" \
    -c "import aiohttp_apispec"
then
    echo "[FAIL] CALDERA Python dependency check failed"
    exit 1
fi

echo "[OK] CALDERA Python dependencies"

if ! systemctl is-active \
    --quiet "$SERVICE"
then
    echo "[FAIL] CALDERA systemd service inactive"
    exit 1
fi

echo "[OK] CALDERA systemd service active"

HTTP_CODE="$(
    curl \
        --silent \
        --output /dev/null \
        --write-out '%{http_code}' \
        --max-time 5 \
        http://127.0.0.1:8888 \
        || true
)"

if [[ "$HTTP_CODE" =~ ^(200|302|401)$ ]]; then
    echo "[OK] CALDERA HTTP endpoint: ${HTTP_CODE}"
else
    echo "[FAIL] CALDERA HTTP endpoint: ${HTTP_CODE}"
    exit 1
fi

if ss -ltn | grep -q ':8888 '; then
    echo "[OK] TCP/8888 listening"
else
    echo "[FAIL] TCP/8888 not listening"
    exit 1
fi

echo "[OK] CALDERA validation completed"