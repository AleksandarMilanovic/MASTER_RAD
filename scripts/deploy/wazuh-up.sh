#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

WAZUH_DIR="${PROJECT_ROOT}/security-platform/wazuh"

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
echo " HCR Wazuh Deployment"
echo "======================================"

#
# 1. Required networks
#

for network in \
    hcr-security \
    hcr-case-management
do
    if ! docker network inspect \
        "$network" >/dev/null 2>&1
    then
        echo "[FAIL] Missing network: $network"
        exit 1
    fi
done

echo "[OK] Required networks available"


#
# 2. Integration secret
#

if [[ ! -s \
    "${PROJECT_ROOT}/secrets/thehive-wazuh-api-key" ]]
then
    echo "[WARN] TheHive API key secret does not exist yet."
    echo "[WARN] Integration setup will be required later."
fi


#
# 3. Compose validation
#

cd "$WAZUH_DIR"

echo "[INFO] Validating Wazuh Compose..."

docker compose config >/dev/null

echo "[OK] Wazuh Compose valid"


#
# 4. Start stack
#

echo "[INFO] Starting Wazuh..."

docker compose up -d


#
# 5. Wait for containers
#

echo "[INFO] Waiting for Wazuh containers..."

for container in \
    "$MANAGER" \
    "$INDEXER" \
    "$DASHBOARD"
do
    ready=false

    for i in $(seq 1 60); do

        state="$(
            docker inspect \
                --format '{{.State.Status}}' \
                "$container" \
                2>/dev/null || true
        )"

        if [[ "$state" == "running" ]]; then
            echo "[OK] $container running"
            ready=true
            break
        fi

        sleep 2
    done

    if [[ "$ready" != "true" ]]; then
        echo "[FAIL] Container did not start: $container"
        exit 1
    fi
done


#
# 6. Wait for required Wazuh daemons
#

echo "[INFO] Waiting for required Wazuh Manager services..."

manager_ready=false

for attempt in $(seq 1 60); do

    status_output="$(
        docker exec "$MANAGER" \
            /var/ossec/bin/wazuh-control status \
            2>/dev/null || true
    )"

    missing=()

    for daemon in "${REQUIRED_DAEMONS[@]}"; do

        if ! grep -Fq \
            "${daemon} is running" \
            <<< "$status_output"
        then
            missing+=("$daemon")
        fi

    done

    if (( ${#missing[@]} == 0 )); then
        manager_ready=true
        break
    fi

    echo \
        "[INFO] Waiting for Wazuh services (${attempt}/60): ${missing[*]}"

    sleep 5
done


if [[ "$manager_ready" != "true" ]]; then

    echo "[FAIL] Required Wazuh services did not become ready"

    echo
    echo "=== Wazuh status ==="

    docker exec "$MANAGER" \
        /var/ossec/bin/wazuh-control status \
        || true

    echo
    echo "=== Latest Wazuh log ==="

    docker exec "$MANAGER" \
        tail -n 50 \
        /var/ossec/logs/ossec.log \
        || true

    exit 1
fi

echo "[OK] Required Wazuh Manager services are running"


#
# 7. Show optional stopped services for information only
#

echo
echo "[INFO] Optional/inactive Wazuh services:"

docker exec "$MANAGER" \
    /var/ossec/bin/wazuh-control status \
    2>/dev/null |
grep "not running" \
|| echo "[INFO] None"

echo


#
# 8. Communication ports
#

echo "[INFO] Checking Wazuh communication ports..."

for port in 1514 1515 55000; do

    if ss -ltn |
       grep -q ":${port} "
    then
        echo "[OK] TCP/${port} listening"
    else
        echo "[FAIL] TCP/${port} not listening"
        exit 1
    fi

done


#
# 9. Dashboard readiness
#

echo "[INFO] Waiting for Wazuh Dashboard..."

dashboard_ready=false
HTTP_CODE="000"

for i in $(seq 1 60); do

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
        dashboard_ready=true
        break
    fi

    sleep 5
done


if [[ "$dashboard_ready" != "true" ]]; then

    echo "[FAIL] Wazuh Dashboard did not become reachable"

    docker logs \
        "$DASHBOARD" \
        --tail 50 \
        || true

    exit 1
fi


echo "[OK] Wazuh Dashboard reachable: HTTP ${HTTP_CODE}"

echo
echo "======================================"
echo " Wazuh stack ready"
echo "======================================"