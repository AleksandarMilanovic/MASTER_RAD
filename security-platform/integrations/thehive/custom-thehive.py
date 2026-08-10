#!/usr/bin/env python3

import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


INTEGRATION_LOG = Path("/var/ossec/logs/integrations-thehive.log")
DEBUG_LOG = Path("/var/ossec/logs/custom-thehive.log")
SECRET_PATH = Path("/run/secrets/thehive_api_key")
DEFAULT_THEHIVE_URL = "http://thehive:9000"


def safe_log(path, message):
    try:
        with path.open("a", encoding="utf-8") as log_file:
            log_file.write(
                f"{time.strftime('%Y-%m-%d %H:%M:%S')} {message}\n"
            )
    except Exception:
        # Logging must never break the integration itself.
        pass


def write_log(message):
    safe_log(INTEGRATION_LOG, message)


def debug_log(message):
    safe_log(DEBUG_LOG, message)


def get_nested(data, path, default=None):
    current = data

    for key in path:
        if not isinstance(current, dict):
            return default

        current = current.get(key)

        if current is None:
            return default

    return current


def normalize_list(value):
    if value is None:
        return []

    if isinstance(value, list):
        return [
            str(item).strip()
            for item in value
            if item is not None and str(item).strip()
        ]

    value = str(value).strip()
    return [value] if value else []


def append_field(lines, label, value):
    if value is None:
        return

    value = str(value).strip()

    if value:
        lines.append(f"**{label}:** {value}")


def map_severity(wazuh_level):
    """
    HCR normalization policy:
      Wazuh 0-6   -> TheHive Low (1)
      Wazuh 7-9   -> TheHive Medium (2)
      Wazuh 10-12 -> TheHive High (3)
      Wazuh 13+   -> TheHive Critical (4)
    """
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


def build_description(wazuh_alert):
    rule = wazuh_alert.get("rule", {}) or {}
    agent = wazuh_alert.get("agent", {}) or {}

    win_system = get_nested(
        wazuh_alert,
        ["data", "win", "system"],
        {},
    ) or {}

    eventdata = get_nested(
        wazuh_alert,
        ["data", "win", "eventdata"],
        {},
    ) or {}

    mitre_ids = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "mitre", "id"],
            [],
        )
    )

    mitre_tactics = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "mitre", "tactic"],
            [],
        )
    )

    mitre_techniques = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "mitre", "technique"],
            [],
        )
    )

    groups = normalize_list(rule.get("groups"))

    lines = [
        "## Detection Summary",
        "",
    ]

    append_field(lines, "Wazuh Alert ID", wazuh_alert.get("id"))
    append_field(lines, "Timestamp", wazuh_alert.get("timestamp"))
    append_field(lines, "Rule ID", rule.get("id"))
    append_field(lines, "Rule Level", rule.get("level"))
    append_field(lines, "Rule Description", rule.get("description"))

    lines += [
        "",
        "## Affected Endpoint",
        "",
    ]

    append_field(lines, "Agent ID", agent.get("id"))
    append_field(lines, "Agent Name", agent.get("name"))
    append_field(lines, "Agent IP", agent.get("ip"))

    if mitre_ids or mitre_tactics or mitre_techniques:
        lines += [
            "",
            "## MITRE ATT&CK",
            "",
        ]

        if mitre_ids:
            append_field(lines, "Technique IDs", ", ".join(mitre_ids))

        if mitre_tactics:
            append_field(lines, "Tactics", ", ".join(mitre_tactics))

        if mitre_techniques:
            append_field(lines, "Techniques", ", ".join(mitre_techniques))

    event_context = []

    def event_field(label, value):
        if value is None:
            return

        value = str(value).strip()

        if value:
            event_context.append(f"**{label}:** {value}")

    event_field("Windows Event ID", win_system.get("eventID"))
    event_field("Channel", win_system.get("channel"))
    event_field("Computer", win_system.get("computer"))

    event_field("User", eventdata.get("user"))
    event_field("Process", eventdata.get("image"))
    event_field("Parent Process", eventdata.get("parentImage"))
    event_field("Command Line", eventdata.get("commandLine"))
    event_field("Parent Command Line", eventdata.get("parentCommandLine"))
    event_field("Target File", eventdata.get("targetFilename"))
    event_field("Source IP", eventdata.get("sourceIp"))
    event_field("Source Port", eventdata.get("sourcePort"))
    event_field("Destination IP", eventdata.get("destinationIp"))
    event_field("Destination Port", eventdata.get("destinationPort"))
    event_field("Destination Hostname", eventdata.get("destinationHostname"))
    event_field("Query Name", eventdata.get("queryName"))
    event_field("Hashes", eventdata.get("hashes"))

    if event_context:
        lines += [
            "",
            "## Event Context",
            "",
        ]
        lines.extend(event_context)

    lines += [
        "",
        "## Wazuh Metadata",
        "",
    ]

    append_field(
        lines,
        "Decoder",
        get_nested(wazuh_alert, ["decoder", "name"]),
    )
    append_field(lines, "Location", wazuh_alert.get("location"))

    if groups:
        append_field(lines, "Rule Groups", ", ".join(groups))

    return "\n".join(lines)


def build_thehive_alert(wazuh_alert):
    rule_id = str(
        get_nested(
            wazuh_alert,
            ["rule", "id"],
            "unknown",
        )
    )

    rule_level = get_nested(
        wazuh_alert,
        ["rule", "level"],
        0,
    )

    rule_description = get_nested(
        wazuh_alert,
        ["rule", "description"],
        "Wazuh security alert",
    )

    agent_name = get_nested(
        wazuh_alert,
        ["agent", "name"],
        "unknown-agent",
    )

    agent_id = str(
        get_nested(
            wazuh_alert,
            ["agent", "id"],
            "unknown",
        )
    )

    timestamp = wazuh_alert.get(
        "timestamp",
        str(int(time.time())),
    )

    # Prefer Wazuh's own alert ID because it is stable and unique.
    wazuh_alert_id = wazuh_alert.get("id")

    if wazuh_alert_id:
        source_ref = f"wazuh-{wazuh_alert_id}"
    else:
        source_ref = f"wazuh-{agent_id}-{rule_id}-{timestamp}"

    rule_groups = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "groups"],
            [],
        )
    )

    mitre_ids = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "mitre", "id"],
            [],
        )
    )

    mitre_tactics = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "mitre", "tactic"],
            [],
        )
    )

    mitre_techniques = normalize_list(
        get_nested(
            wazuh_alert,
            ["rule", "mitre", "technique"],
            [],
        )
    )

    tags = [
        "wazuh",
        "hcr",
        f"wazuh-rule-{rule_id}",
        f"wazuh-level-{rule_level}",
        f"agent-{agent_name}",
    ]

    tags.extend(mitre_ids)
    tags.extend(mitre_tactics)
    tags.extend(mitre_techniques)

    for group in rule_groups:
        tags.append(f"wazuh-group-{group}")

    # Remove duplicates while preserving original order.
    tags = list(dict.fromkeys(tags))

    return {
        "type": "wazuh",
        "source": "HCR-Wazuh",
        "sourceRef": source_ref,
        "title": rule_description,
        "description": build_description(wazuh_alert),
        "severity": map_severity(rule_level),
        "tlp": 1,
        "pap": 1,
        "tags": tags,
    }


def send_alert(thehive_url, api_key, payload):
    endpoint = thehive_url.rstrip("/") + "/api/v1/alert"

    request = urllib.request.Request(
        endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with urllib.request.urlopen(
        request,
        timeout=10,
    ) as response:
        body = response.read().decode("utf-8")
        return response.status, body


def load_api_key():
    try:
        api_key = SECRET_PATH.read_text(encoding="utf-8").strip()
    except OSError as error:
        raise RuntimeError(
            f"Unable to read TheHive API key secret: {error}"
        ) from error

    if not api_key:
        raise RuntimeError("TheHive API key secret is empty")

    return api_key


def main():
    debug_log(f"START pid={os.getpid()} argc={len(sys.argv)}")

    if len(sys.argv) < 2:
        print(
            "Usage: custom-thehive <alert_file> [api_key] [thehive_url]",
            file=sys.stderr,
        )
        return 1

    alert_file = sys.argv[1]
    thehive_url = DEFAULT_THEHIVE_URL

    # Wazuh custom integration arguments:
    # argv[1] = alert file
    # argv[2] = API key (unused; secret is read from /run/secrets)
    # argv[3] = hook URL
    if len(sys.argv) > 3 and sys.argv[3]:
        thehive_url = sys.argv[3]

    debug_log(f"alert_file={alert_file}")
    debug_log(f"thehive_url={thehive_url}")

    try:
        api_key = load_api_key()

        with open(
            alert_file,
            "r",
            encoding="utf-8",
        ) as file:
            wazuh_alert = json.load(file)

        rule_id = get_nested(wazuh_alert, ["rule", "id"], "unknown")
        rule_level = get_nested(wazuh_alert, ["rule", "level"], "unknown")
        agent_name = get_nested(
            wazuh_alert,
            ["agent", "name"],
            "unknown",
        )

        debug_log(
            "alert parsed "
            f"rule_id={rule_id} "
            f"level={rule_level} "
            f"agent={agent_name}"
        )

        payload = build_thehive_alert(wazuh_alert)

        debug_log(f"sourceRef={payload.get('sourceRef')}")
        write_log(
            "Prepared TheHive alert "
            f"sourceRef={payload.get('sourceRef')} "
            f"rule_id={rule_id} "
            f"level={rule_level} "
            f"agent={agent_name}"
        )

        status, response = send_alert(
            thehive_url,
            api_key,
            payload,
        )

        debug_log(f"TheHive response HTTP={status}")
        write_log(
            f"TheHive alert accepted "
            f"sourceRef={payload.get('sourceRef')} "
            f"HTTP={status}"
        )

        if 200 <= status < 300:
            print(
                f"TheHive alert created successfully: HTTP {status}"
            )
            return 0

        print(
            f"TheHive returned HTTP {status}: {response}",
            file=sys.stderr,
        )
        return 2

    except urllib.error.HTTPError as error:
        body = error.read().decode(
            "utf-8",
            errors="replace",
        )

        # TheHive treats type + source + sourceRef as the alert identity.
        # A repeated Wazuh alert is therefore an idempotent success.
        if error.code == 400 and "already exists" in body:
            debug_log("Duplicate alert detected; ignored")
            write_log("Duplicate TheHive alert detected; ignored")
            print(
                "TheHive alert already exists; duplicate ignored"
            )
            return 0

        debug_log(
            f"TheHive HTTPError={error.code} body={body[:500]}"
        )
        write_log(
            f"TheHive HTTP error {error.code}: {body[:500]}"
        )

        print(
            f"TheHive HTTP error {error.code}: {body}",
            file=sys.stderr,
        )
        return 2

    except Exception as error:
        debug_log(
            f"ERROR {type(error).__name__}: {error}"
        )
        write_log(
            f"TheHive integration error: "
            f"{type(error).__name__}: {error}"
        )

        print(
            f"TheHive integration error: {error}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    sys.exit(main())