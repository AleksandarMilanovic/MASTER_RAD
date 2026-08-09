#!/usr/bin/env python3

import os
import json
import sys
import time
import urllib.error
import urllib.request

from pathlib import Path

LOG_FILE = Path("/var/ossec/logs/integrations-thehive.log")

def write_log(message):
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} {message}\n")

def get_nested(data, path, default=None):
    current = data

    for key in path:
        if not isinstance(current, dict):
            return default

        current = current.get(key)

        if current is None:
            return default

    return current


def map_severity(wazuh_level):
    try:
        level = int(wazuh_level)
    except (TypeError, ValueError):
        return 1

    if level >= 13:
        return 4

    if level >= 10:
        return 3

    if level >= 7:
        return 2

    return 1


def build_thehive_alert(wazuh_alert):
    rule_id = str(
        get_nested(wazuh_alert, ["rule", "id"], "unknown")
    )

    rule_level = get_nested(
        wazuh_alert,
        ["rule", "level"],
        0
    )

    rule_description = get_nested(
        wazuh_alert,
        ["rule", "description"],
        "Wazuh security alert"
    )

    agent_name = get_nested(
        wazuh_alert,
        ["agent", "name"],
        "unknown-agent"
    )

    agent_id = str(
        get_nested(
            wazuh_alert,
            ["agent", "id"],
            "unknown"
        )
    )

    timestamp = wazuh_alert.get(
        "timestamp",
        str(int(time.time()))
    )

    source_ref = (
        f"wazuh-{agent_id}-{rule_id}-"
        f"{timestamp}"
    )

    description = (
        f"Wazuh Rule ID: {rule_id}\n"
        f"Wazuh Rule Level: {rule_level}\n"
        f"Agent: {agent_name}\n"
        f"Agent ID: {agent_id}\n\n"
        f"{rule_description}"
    )

    tags = [
        "wazuh",
        "hcr",
        f"wazuh-rule-{rule_id}",
        f"agent-{agent_name}"
    ]

    return {
        "type": "wazuh",
        "source": "HCR-Wazuh",
        "sourceRef": source_ref,
        "title": rule_description,
        "description": description,
        "severity": map_severity(rule_level),
        "tlp": 1,
        "pap": 1,
        "tags": tags
    }


def send_alert(thehive_url, api_key, payload):
    endpoint = (
        thehive_url.rstrip("/")
        + "/api/v1/alert"
    )

    request = urllib.request.Request(
        endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        },
        method="POST"
    )

    with urllib.request.urlopen(
        request,
        timeout=10
    ) as response:
        body = response.read().decode("utf-8")

        return response.status, body

def load_api_key():
    secret_path = "/run/secrets/thehive_api_key"

    try:
        with open(secret_path, "r", encoding="utf-8") as file:
            api_key = file.read().strip()
    except OSError as error:
        raise RuntimeError(
            f"Unable to read TheHive API key secret: {error}"
        ) from error

    if not api_key:
        raise RuntimeError(
            "TheHive API key secret is empty"
        )

    return api_key


LOG_FILE = "/var/ossec/logs/custom-thehive-debug.log"


def debug_log(message):
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as log_file:
            log_file.write(
                f"{time.strftime('%Y-%m-%d %H:%M:%S')} "
                f"{message}\n"
            )
    except Exception:
        pass

def main():
    debug_log(
        f"START pid={os.getpid()} argc={len(sys.argv)}"
    )

    if len(sys.argv) < 2:
        print(
            "Usage: custom-thehive "
            "<alert_file> [api_key] [thehive_url]",
            file=sys.stderr
        )
        return 1

    alert_file = sys.argv[1]

    debug_log(
        f"alert_file={alert_file}"
    )

    # Wazuh custom integration arguments:
    # argv[1] = alert file
    # argv[2] = api_key (may be empty)
    # argv[3] = hook_url
    
    thehive_url = "http://thehive:9000"

    debug_log(
        f"thehive_url={thehive_url}"
    )

    api_key = load_api_key()

    if len(sys.argv) > 3 and sys.argv[3]:
        thehive_url = sys.argv[3]

    try:
        api_key = load_api_key()

        with open(
            alert_file,
            "r",
            encoding="utf-8"
        ) as file:
            wazuh_alert = json.load(file)
            write_log(f"Loaded Wazuh alert from {alert_file}")

        debug_log(
            "alert parsed "
            f"rule_id={get_nested(wazuh_alert, ['rule', 'id'], 'unknown')} "
            f"level={get_nested(wazuh_alert, ['rule', 'level'], 'unknown')} "
            f"agent={get_nested(wazuh_alert, ['agent', 'name'], 'unknown')}"
        )

        payload = build_thehive_alert(
            wazuh_alert
        )

        debug_log(
            f"sourceRef={payload.get('sourceRef')}"
        )
        write_log(f"Built TheHive alert: {payload}")

        status, response = send_alert(
            thehive_url,
            api_key,
            payload
        )
        write_log(f"Sent TheHive alert: HTTP {status}")
        debug_log(
            f"TheHive response HTTP={status}"
        )

        if 200 <= status < 300:
            print(
                f"TheHive alert created "
                f"successfully: HTTP {status}"
            )
            write_log(f"TheHive alert created successfully: HTTP {status}")
            return 0

        print(
            f"TheHive returned HTTP {status}: "
            f"{response}",
            file=sys.stderr
        )
        write_log(f"TheHive returned HTTP {status}: {response}")

        return 2

    except urllib.error.HTTPError as error:
        body = error.read().decode(
            "utf-8",
            errors="replace"
        )
        debug_log(
            f"TheHive HTTPError={error.code} body={body[:500]}"
        )
        write_log(f"TheHive HTTP error {error.code}: {body}")

        print(
            f"TheHive HTTP error "
            f"{error.code}: {body}",
            file=sys.stderr
        )

        return 2

    except Exception as error:
        print(
            f"TheHive integration error: "
            f"{error}",
            file=sys.stderr
        )
        debug_log(
            f"ERROR {type(error).__name__}: {error}"
        )
        write_log(f"TheHive integration error: {error}")

        return 1


if __name__ == "__main__":
    sys.exit(main())