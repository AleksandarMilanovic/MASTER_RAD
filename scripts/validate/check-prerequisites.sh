#!/usr/bin/env bash
set -Eeuo pipefail

failures=0

check_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    printf '[OK] %s: %s\n' "$command_name" "$(command -v "$command_name")"
  else
    printf '[FAIL] Nedostaje komanda: %s\n' "$command_name"
    failures=$((failures + 1))
  fi
}

echo "=== Hybrid Cyber Range: provera preduslova ==="
check_command docker
check_command git

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    echo "[OK] Docker daemon je dostupan"
  else
    echo "[FAIL] Docker je instaliran, ali daemon nije dostupan"
    failures=$((failures + 1))
  fi

  if docker compose version >/dev/null 2>&1; then
    echo "[OK] Docker Compose plugin: $(docker compose version --short)"
  else
    echo "[FAIL] Docker Compose plugin nije dostupan"
    failures=$((failures + 1))
  fi
fi

if [[ -r /proc/meminfo ]]; then
  mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  mem_gb=$((mem_kb / 1024 / 1024))
  echo "[INFO] Vidljivi RAM: približno ${mem_gb} GB"
  if (( mem_gb < 8 )); then
    echo "[WARN] Za Wazuh single-node preporučeno je najmanje 8 GB RAM-a"
  fi
fi

if command -v nproc >/dev/null 2>&1; then
  cpu_count=$(nproc)
  echo "[INFO] Vidljiva CPU jezgra: ${cpu_count}"
  if (( cpu_count < 4 )); then
    echo "[WARN] Za Wazuh single-node preporučena su najmanje 4 jezgra"
  fi
fi

available_kb=$(df -Pk . | awk 'NR==2 {print $4}')
available_gb=$((available_kb / 1024 / 1024))
echo "[INFO] Slobodan prostor na trenutnom filesystem-u: približno ${available_gb} GB"
if (( available_gb < 50 )); then
  echo "[WARN] Za početni Wazuh Docker deployment planirati najmanje 50 GB"
fi

if (( failures > 0 )); then
  echo "=== Provera završena sa ${failures} greškom/greškama ==="
  exit 1
fi

echo "=== Osnovni preduslovi su ispunjeni ==="
