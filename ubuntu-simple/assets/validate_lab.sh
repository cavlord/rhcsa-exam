#!/usr/bin/env bash
set -Eeuo pipefail

PASS=0
FAIL=0

check() {
  local name="$1"
  local cmd="$2"

  if eval "$cmd"; then
    echo "[PASS] $name"
    ((PASS++))
  else
    echo "[FAIL] $name"
    ((FAIL++))
  fi
}

check "Hostname configured" "hostnamectl | grep -q node1.net11.example.com"
check "HTTPD running on port 82" "ss -tlnp | grep -q ':82'"
check "Manager group exists" "getent group manager"
check "Simone secondary group" "id simone | grep -q manager"
check "Pandora no-login shell" "grep pandora /etc/passwd | grep -q nologin"
check "Shared directory permissions" "stat -c '%a' /shared/manager | grep -q 2770"
check "Cron exists" "crontab -u walhalla -l | grep -q 'EX200 Test'"
check "Autofs configured" "systemctl is-active autofs | grep -q active"
check "Chrony configured" "grep -q servera.lab.example.com /etc/chrony.conf"
check "LVM exists" "lvs | grep -q wshare"
check "Swap enabled" "swapon --show | grep -q swap"

TOTAL=$((PASS+FAIL))

echo
printf 'PASS: %s\n' "$PASS"
printf 'FAIL: %s\n' "$FAIL"
printf 'TOTAL: %s\n' "$TOTAL"
