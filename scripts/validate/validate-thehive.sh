#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== TheHive Validation ==="

required_containers=(
    cassandra
    elasticsearch
    thehive
    nginx
)

for container in "${required_containers[@]}"; do

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

health="$(
    docker inspect \
        --format '{{.State.Health.Status}}' \
        thehive
)"

if [[ "$health" != "healthy" ]]; then
    echo "[FAIL] TheHive health: $health"
    exit 1
fi

echo "[OK] TheHive healthy"

HTTP_CODE="$(
    docker exec thehive \
        curl \
        -s \
        -o /dev/null \
        -w '%{http_code}' \
        http://localhost:9000/api/status
)"

if [[ "$HTTP_CODE" != "200" ]]; then
    echo "[FAIL] TheHive API returned HTTP ${HTTP_CODE}"
    exit 1
fi

echo "[OK] TheHive API: HTTP ${HTTP_CODE}"
echo "[OK] TheHive validation completed"
