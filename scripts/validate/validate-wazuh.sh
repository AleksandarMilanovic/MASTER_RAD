#!/usr/bin/env bash
set -Eeuo pipefail

MANAGER="wazuh-wazuh.manager-1"
INDEXER="wazuh-wazuh.indexer-1"
DASHBOARD="wazuh-wazuh.dashboard-1"

REQUIRED_DAEMONS=(
    wazuh-modulesd
    wazuh-monitord
    wazuh-logcollector
    wazuh-remoted
    wazuh-syscheckd
    wazuh-analysisd
    wazuh-execd
    wazuh-db
    wazuh-authd
    wazuh-integratord
    wazuh-apid
)

echo "======================================"
echo " HCR Wazuh Validation"
echo "======================================"

#
# 1. Container validation
#

echo
echo "=== Containers ==="

for container in \
    "$MANAGER" \
    "$INDEXER" \
    "$DASHBOARD"
do

    if ! docker inspect "$container" >/dev/null 2>&1; then
        echo "[FAIL] Missing container: $container"
        exit 1
    fi

    state="$(
        docker inspect \
            --format '{{.State.Status}}' \
            "$container"
    )"

    if [[ "$state" != "running" ]]; then
        echo "[FAIL] $container state: $state"
        exit 1
    fi

    echo "[OK] $container running"
done


#
# 2. Required Wazuh Manager daemons
#

echo
echo "=== Required Wazuh Manager Services ==="

status_output="$(
    docker exec "$MANAGER" \
        /var/ossec/bin/wazuh-control status \
        2>/dev/null || true
)"

if [[ -z "$status_output" ]]; then
    echo "[FAIL] Unable to retrieve Wazuh service status"
    exit 1
fi

failures=0

for daemon in "${REQUIRED_DAEMONS[@]}"; do

    if grep -Fq \
        "${daemon} is running" \
        <<< "$status_output"
    then
        echo "[OK] $daemon"
    else
        echo "[FAIL] $daemon"
        failures=$((failures + 1))
    fi

done

if (( failures > 0 )); then
    echo
    echo "[FAIL] ${failures} required Wazuh daemon(s) unavailable"

    echo
    echo "=== Full Wazuh status ==="
    echo "$status_output"

    exit 1
fi

echo
echo "[OK] All required Wazuh Manager services running"


#
# 3. Optional inactive services
#

echo
echo "=== Optional / Inactive Wazuh Services ==="

optional_output="$(
    grep "not running" \
        <<< "$status_output" \
        || true
)"

if [[ -n "$optional_output" ]]; then
    echo "$optional_output"
else
    echo "[INFO] None"
fi


#
# 4. Wazuh communication ports
#

echo
echo "=== Network Ports ==="

required_ports=(
    1514
    1515
    55000
)

for port in "${required_ports[@]}"; do

    if ss -ltn |
       grep -q ":${port} "
    then
        echo "[OK] TCP/${port} listening"
    else
        echo "[FAIL] TCP/${port} unavailable"
        exit 1
    fi

done


#
# 5. Dashboard HTTP validation
#

echo
echo "=== Wazuh Dashboard ==="

HTTP_CODE="$(
    curl \
        -k \
        -s \
        -o /dev/null \
        -w '%{http_code}' \
        --max-time 5 \
        https://127.0.0.1 \
        || true
)"

if [[ "$HTTP_CODE" =~ ^(200|302|401)$ ]]; then
    echo "[OK] Wazuh Dashboard reachable: HTTP ${HTTP_CODE}"
else
    echo "[FAIL] Wazuh Dashboard returned HTTP ${HTTP_CODE}"
    exit 1
fi


#
# 6. Final result
#

echo
echo "======================================"
echo " Wazuh validation completed successfully"
echo "======================================"