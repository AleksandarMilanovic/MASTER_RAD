#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"

cd "$PROJECT_ROOT"

START_TIME=$(date +%s)

echo
echo "================================================"
echo "       HYBRID CYBER RANGE DEPLOYMENT"
echo "================================================"
echo

run_stage() {
    local number="$1"
    local total="$2"
    local description="$3"
    local command="$4"

    echo
    echo "------------------------------------------------"
    echo " [$number/$total] $description"
    echo "------------------------------------------------"

    if "$command"; then
        echo "[OK] $description"
    else
        echo "[FAIL] $description"
        exit 1
    fi
}


run_stage \
    1 7 \
    "Checking prerequisites" \
    ./scripts/validate/check-prerequisites.sh


run_stage \
    2 7 \
    "Preparing network infrastructure" \
    ./scripts/deploy/networks-up.sh


run_stage \
    3 7 \
    "Starting Wazuh" \
    ./scripts/deploy/wazuh-up.sh


run_stage \
    4 7 \
    "Starting TheHive" \
    ./scripts/deploy/thehive-up.sh


run_stage \
    5 7 \
    "Configuring Wazuh-TheHive integration" \
    ./scripts/deploy/configure-thehive-integration.sh


run_stage \
    6 7 \
    "Starting CALDERA" \
    ./scripts/deploy/caldera-up.sh


run_stage \
    7 7 \
    "Starting monitoring stack" \
    ./scripts/deploy/monitoring-up.sh


echo
echo "------------------------------------------------"
echo " Running final validation"
echo "------------------------------------------------"

./scripts/validate/validate-all.sh


END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))


echo
echo "================================================"
echo "       HYBRID CYBER RANGE READY"
echo "================================================"
echo
echo "Deployment completed in ${DURATION} seconds."
echo
echo "Access points:"
echo
echo "  Wazuh Dashboard : https://192.168.100.10"
echo "  TheHive         : https://192.168.100.10:9443"
echo "  CALDERA         : http://192.168.100.10:8888"
echo "  Prometheus      : http://192.168.100.10:9090"
echo "  Grafana         : http://192.168.100.10:3000"
echo
echo "================================================"
