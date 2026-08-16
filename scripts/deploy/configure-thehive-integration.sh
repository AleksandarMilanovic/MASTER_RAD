#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="/opt/hybrid-cyber-range"

WAZUH_DIR="${PROJECT_ROOT}/security-platform/wazuh"

INTEGRATION_SOURCE="${PROJECT_ROOT}/security-platform/integrations/thehive/custom-thehive.py"

SECRET_DIR="${PROJECT_ROOT}/secrets"

SECRET_FILE="${SECRET_DIR}/thehive-wazuh-api-key"

WAZUH_CONTAINER="wazuh-wazuh.manager-1"

CASE_NETWORK="hcr-case-management"


echo "=========================================="
echo " HCR Wazuh -> TheHive Integration Setup"
echo "=========================================="


#
# 1. Provera potrebnih fajlova
#

if [ ! -f "$INTEGRATION_SOURCE" ]; then
    echo "[FAIL] Integration script not found:"
    echo "$INTEGRATION_SOURCE"
    exit 1
fi


#
# 2. Kreiranje secrets direktorijuma
#

sudo install \
    -d \
    -m 750 \
    "$SECRET_DIR"


#
# 3. Kreiranje API secret-a ako ne postoji
#

if [ ! -s "$SECRET_FILE" ]; then

    echo
    echo "TheHive API key is not configured."

    read -rsp \
        "Enter TheHive API key: " \
        THEHIVE_API_KEY

    echo

    if [ -z "$THEHIVE_API_KEY" ]; then
        echo "[FAIL] API key cannot be empty."
        exit 1
    fi

    printf '%s' "$THEHIVE_API_KEY" |
        sudo tee "$SECRET_FILE" >/dev/null

    unset THEHIVE_API_KEY

fi


#
# 4. Provera case-management mreže
#

if ! docker network inspect \
    "$CASE_NETWORK" >/dev/null 2>&1
then
    echo "[FAIL] Required network does not exist: $CASE_NETWORK"
    echo "[INFO] Run network deployment first."
    exit 1
fi

echo "[OK] Required network exists: $CASE_NETWORK"


#
# 5. Validacija Wazuh Compose konfiguracije
#

cd "$WAZUH_DIR"

docker compose config >/dev/null

echo "[OK] Wazuh Compose configuration valid"


#
# 6. Pokretanje Wazuh Manager-a
#

docker compose up -d wazuh.manager


#
# 7. Čekanje na container
#

echo "[INFO] Waiting for Wazuh Manager..."

for i in $(seq 1 30); do

    if docker exec \
        "$WAZUH_CONTAINER" \
        id wazuh >/dev/null 2>&1
    then
        break
    fi

    sleep 2

done


#
# 8. Dinamičko određivanje Wazuh GID-a
#

WAZUH_GID="$(
    docker exec \
        "$WAZUH_CONTAINER" \
        id -g wazuh
)"

echo "[INFO] Wazuh GID: ${WAZUH_GID}"


#
# 9. Podešavanje prava nad secret-om
#

sudo chown \
    root:"${WAZUH_GID}" \
    "$SECRET_FILE"

sudo chmod \
    640 \
    "$SECRET_FILE"


#
# 10. Provera da li je secret montiran
#

if ! docker exec \
    -u wazuh \
    "$WAZUH_CONTAINER" \
    test -r /run/secrets/thehive_api_key
then

    echo "[INFO] Secret is not mounted yet."
    echo "[INFO] Recreating Wazuh Manager."

    docker compose up \
        -d \
        --force-recreate \
        wazuh.manager

    sleep 10

fi


#
# 11. Ponovna provera prava
#

if docker exec \
    -u wazuh \
    "$WAZUH_CONTAINER" \
    test -r /run/secrets/thehive_api_key
then

    echo "[OK] Wazuh user can read TheHive API secret"
else

    echo "[FAIL] Wazuh user cannot read TheHive API secret"
    exit 1

fi


#
# 12. Instalacija custom integracije
#

docker cp \
    "$INTEGRATION_SOURCE" \
    "${WAZUH_CONTAINER}:/var/ossec/integrations/custom-thehive"

docker exec \
    "$WAZUH_CONTAINER" \
    chown root:wazuh \
    /var/ossec/integrations/custom-thehive

docker exec \
    "$WAZUH_CONTAINER" \
    chmod 750 \
    /var/ossec/integrations/custom-thehive


#
# 13. Python syntax validation
#

docker exec \
    "$WAZUH_CONTAINER" \
    python3 -m py_compile \
    /var/ossec/integrations/custom-thehive

echo "[OK] custom-thehive installed"


#
# 14. TheHive DNS test
#

docker exec \
    "$WAZUH_CONTAINER" \
    getent hosts thehive >/dev/null

echo "[OK] Docker DNS resolves TheHive"


#
# 15. TheHive API connectivity
#

HTTP_CODE="$(
    docker exec \
        "$WAZUH_CONTAINER" \
        curl \
        -sS \
        -o /dev/null \
        -w '%{http_code}' \
        http://thehive:9000/api/status
)"

if [ "$HTTP_CODE" != "200" ]; then

    echo "[FAIL] TheHive API returned HTTP ${HTTP_CODE}"
    exit 1

fi

echo "[OK] TheHive API reachable"


#
# Final
#

echo
echo "=========================================="
echo " Wazuh -> TheHive integration configured"
echo "=========================================="