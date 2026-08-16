#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

COMPOSE_FILE="compose/compose.yaml"

echo "======================================"
echo " HCR Network Deployment"
echo "======================================"

if [[ ! -f .env ]]; then
    echo "[FAIL] Missing .env"
    echo "[INFO] Create it from .env.example"
    exit 1
fi

echo "[INFO] Validating base Compose configuration..."

docker compose \
    --env-file .env \
    -f "$COMPOSE_FILE" \
    config >/dev/null

echo "[OK] Base Compose configuration valid"

echo "[INFO] Initializing HCR networks..."

docker compose \
    --env-file .env \
    -f "$COMPOSE_FILE" \
    --profile bootstrap \
    up \
    --no-recreate \
    network-bootstrap

docker compose \
    --env-file .env \
    -f "$COMPOSE_FILE" \
    rm -f network-bootstrap >/dev/null 2>&1 || true


required_networks=(
    hcr-management
    hcr-security
    hcr-monitoring
    hcr-corporate
    hcr-dmz
    hcr-attacker
    hcr-case-management
    hcr-monitoring-access
)


echo
echo "=== Network validation ==="

failures=0

for network in "${required_networks[@]}"; do

    if docker network inspect "$network" >/dev/null 2>&1; then

        subnet="$(
            docker network inspect "$network" \
                --format '{{(index .IPAM.Config 0).Subnet}}'
        )"

        internal="$(
            docker network inspect "$network" \
                --format '{{.Internal}}'
        )"

        printf \
            '[OK] %-25s %-18s Internal=%s\n' \
            "$network" \
            "$subnet" \
            "$internal"

    else
        echo "[FAIL] Missing network: $network"
        failures=$((failures + 1))
    fi

done


if (( failures > 0 )); then
    echo
    echo "[FAIL] ${failures} required network(s) missing"
    exit 1
fi


echo
echo "[OK] HCR network infrastructure ready"