#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"
THEHIVE_DIR="${PROJECT_ROOT}/security-platform/thehive-vendor/prod1-thehive"

echo "======================================"
echo " HCR TheHive Deployment"
echo "======================================"

if [[ ! -d "$THEHIVE_DIR" ]]; then
    echo "[FAIL] TheHive directory not found:"
    echo "$THEHIVE_DIR"
    exit 1
fi

if [[ ! -f "${THEHIVE_DIR}/.env" ]]; then
    echo "[FAIL] TheHive is not initialized."
    echo "[INFO] Missing: ${THEHIVE_DIR}/.env"
    echo "[INFO] Initial setup must be completed first."
    exit 1
fi

if ! docker network inspect hcr-case-management >/dev/null 2>&1; then
    echo "[FAIL] Missing network: hcr-case-management"
    exit 1
fi

cd "$THEHIVE_DIR"

echo "[INFO] Validating TheHive Compose..."
docker compose config >/dev/null
echo "[OK] TheHive Compose valid"

echo "[INFO] Starting TheHive stack..."
docker compose up -d

echo "[INFO] Waiting for TheHive..."

for i in $(seq 1 60); do
    health="$(
        docker inspect \
            --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
            thehive 2>/dev/null || true
    )"

    if [[ "$health" == "healthy" ]]; then
        echo "[OK] TheHive is healthy"
        exit 0
    fi

    sleep 5
done

echo "[FAIL] TheHive did not become healthy"

docker compose ps
docker compose logs --tail=50 thehive || true

exit 1
