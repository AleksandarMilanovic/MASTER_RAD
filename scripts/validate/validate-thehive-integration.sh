#!/usr/bin/env bash

set -euo pipefail

WAZUH_CONTAINER="wazuh-wazuh.manager-1"

echo "=== Wazuh Integrator ==="

docker exec "$WAZUH_CONTAINER" \
    ps -eo user,group,pid,cmd |
grep '[w]azuh-integratord'


echo
echo "=== Integration configuration ==="

docker exec "$WAZUH_CONTAINER" \
    grep -A6 \
    '<name>custom-thehive</name>' \
    /var/ossec/etc/ossec.conf


echo
echo "=== Integration executable ==="

docker exec "$WAZUH_CONTAINER" \
    test -x /var/ossec/integrations/custom-thehive

echo "[OK] executable"


echo
echo "=== Secret permissions ==="

docker exec \
    -u wazuh \
    "$WAZUH_CONTAINER" \
    test -r /run/secrets/thehive_api_key

echo "[OK] readable"


echo
echo "=== Docker DNS ==="

docker exec "$WAZUH_CONTAINER" \
    getent hosts thehive


echo
echo "=== TheHive API ==="

docker exec "$WAZUH_CONTAINER" \
    curl \
    -sS \
    -o /dev/null \
    -w 'HTTP %{http_code}\n' \
    http://thehive:9000/api/status


echo
echo "=== Latest Integrator errors ==="

docker exec "$WAZUH_CONTAINER" \
    sh -c "
        grep -Ei \
        'custom-thehive|thehive|integrat' \
        /var/ossec/logs/ossec.log |
        tail -n 20
    "


echo
echo "[OK] Integration validation complete"