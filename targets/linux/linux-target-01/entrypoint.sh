#!/usr/bin/env bash
set -Eeuo pipefail

WAZUH_HOME="/var/ossec"
KEY_FILE="${WAZUH_HOME}/etc/client.keys"
PERSISTENT_KEY="/var/ossec/etc/persistent/client.keys"
CONFIG_FILE="${WAZUH_HOME}/etc/ossec.conf"

sed -i \
  '/<enrollment>/,/<\/enrollment>/s#<enabled>yes</enabled>#<enabled>no</enabled>#' \
  "${CONFIG_FILE}"

log() {
    printf '[hcr-entrypoint] %s\n' "$*"
}

log "Isključivanje ugrađenog Wazuh enrollment mehanizma"

stop_agent() {
    log "Zaustavljanje Wazuh agenta"

    "${WAZUH_HOME}/bin/wazuh-control" stop || true

    sleep 2

    pkill -TERM -f "${WAZUH_HOME}/bin/wazuh-" || true
    sleep 2
}

trap stop_agent TERM INT

mkdir -p \
    /lab-data/fim-test \
    /var/ossec/etc/persistent \
    /var/ossec/var/run

touch /var/log/hcr-test.log

chown -R wazuh:wazuh \
    /var/ossec/etc/persistent \
    /var/ossec/var/run

chmod 750 /var/ossec/etc/persistent
chmod 640 /var/log/hcr-test.log

if [[ -s "${PERSISTENT_KEY}" ]]; then
    log "Učitavanje postojećeg agent ključa"

    cp "${PERSISTENT_KEY}" "${KEY_FILE}"
    chown wazuh:wazuh "${KEY_FILE}"
    chmod 640 "${KEY_FILE}"
fi

if [[ ! -s "${KEY_FILE}" ]]; then
    log "Agent nema ključ; pokreće se enrollment"

    enrollment_success=0

    for attempt in $(seq 1 20); do
        log "Enrollment pokušaj ${attempt}/20"

        if "${WAZUH_HOME}/bin/agent-auth" \
            -m "${WAZUH_MANAGER}" \
            -A "${WAZUH_AGENT_NAME}" \
            -G "${WAZUH_AGENT_GROUP}"; then
            enrollment_success=1
            break
        fi

        sleep 5
    done

    if [[ "${enrollment_success}" -ne 1 ]]; then
        log "Enrollment nije uspeo"
        exit 1
    fi

    cp "${KEY_FILE}" "${PERSISTENT_KEY}"
    chown wazuh:wazuh "${PERSISTENT_KEY}"
    chmod 640 "${PERSISTENT_KEY}"
fi

rm -f "${WAZUH_HOME}"/var/run/*.pid
rm -f "${WAZUH_HOME}"/var/run/*.state.temp

log "Validacija konfiguracije"

"${WAZUH_HOME}/bin/wazuh-agentd" -t
"${WAZUH_HOME}/bin/wazuh-syscheckd" -t

log "Pokretanje Wazuh agenta"

"${WAZUH_HOME}/bin/wazuh-control" start

sleep 5

log "Status nakon pokretanja"
"${WAZUH_HOME}/bin/wazuh-control" status || true

while true; do
    if ! pgrep -f "${WAZUH_HOME}/bin/wazuh-agentd" >/dev/null; then
        log "wazuh-agentd više nije aktivan"
        exit 1
    fi

    sleep 10
done