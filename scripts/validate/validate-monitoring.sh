#!/usr/bin/env bash

set -euo pipefail

echo "=== Containers ==="

docker ps \
    --filter name=hcr- \
    --format 'table {{.Names}}\t{{.Status}}'


echo
echo "=== Prometheus ==="

docker exec hcr-prometheus \
    wget -qO- \
    http://127.0.0.1:9090/-/ready

echo


echo
echo "=== Grafana ==="

docker exec hcr-grafana \
    wget -qO- \
    http://127.0.0.1:3000/api/health

echo


echo
echo "=== Prometheus Targets ==="

docker exec hcr-prometheus \
    wget -qO- \
    'http://127.0.0.1:9090/api/v1/query?query=up'

echo


echo
echo "[OK] Monitoring validation completed"
