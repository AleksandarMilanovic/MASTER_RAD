#!/usr/bin/env bash
set -Eeuo pipefail

STATE_FILE="/var/ossec/var/run/wazuh-agentd.state"

pgrep -f '/var/ossec/bin/wazuh-agentd' >/dev/null
pgrep -f '/var/ossec/bin/wazuh-syscheckd' >/dev/null
pgrep -f '/var/ossec/bin/wazuh-logcollector' >/dev/null
pgrep -f '/var/ossec/bin/wazuh-modulesd' >/dev/null

[[ -s /var/ossec/etc/client.keys ]]
[[ -f "${STATE_FILE}" ]]

grep -Eq "status='connected'|status=connected" "${STATE_FILE}"