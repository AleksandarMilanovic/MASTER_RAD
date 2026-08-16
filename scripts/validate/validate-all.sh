#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"

cd "$PROJECT_ROOT"

echo
echo "=========================================="
echo " Hybrid Cyber Range - Full Validation"
echo "=========================================="
echo

run_validation() {
    local name="$1"
    local script="$2"

    echo
    echo "------------------------------------------"
    echo " Validating: $name"
    echo "------------------------------------------"

    if "$script"; then
        echo "[PASS] $name"
    else
        echo "[FAIL] $name"
        return 1
    fi
}

failures=0

run_validation \
    "Wazuh" \
    ./scripts/validate/validate-wazuh.sh \
    || failures=$((failures + 1))

run_validation \
    "TheHive" \
    ./scripts/validate/validate-thehive.sh \
    || failures=$((failures + 1))

run_validation \
    "Wazuh-TheHive Integration" \
    ./scripts/validate/validate-thehive-integration.sh \
    || failures=$((failures + 1))

run_validation \
    "CALDERA" \
    ./scripts/validate/validate-caldera.sh \
    || failures=$((failures + 1))

run_validation \
    "Prometheus/Grafana" \
    ./scripts/validate/validate-monitoring.sh \
    || failures=$((failures + 1))

echo
echo "=========================================="

if (( failures > 0 )); then
    echo " Validation completed with ${failures} failure(s)"
    echo "=========================================="
    exit 1
fi

echo " All Hybrid Cyber Range services are ready"
echo "=========================================="
