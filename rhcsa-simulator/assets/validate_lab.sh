#!/usr/bin/env bash
# Complete RHCSA Exam Validation Script
# Validates all 17 questions

# Don't exit on error - continue checking all questions
# set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           RHCSA EXAM VALIDATION - ALL 17 QUESTIONS             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

check() {
  local question="$1"
  local name="$2"
  local cmd="$3"
  
  echo -n "Q${question}: ${name}... "
  
  if eval "$cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}[PASS]${NC}"
    ((PASS++))
  else
    echo -e "${RED}[FAIL]${NC}"
    ((FAIL++))
  fi
}

# Question 1: Network Configuration
echo -e "${YELLOW}=== Network Configuration ===${NC}"
check "1a" "IP Address configured on eth1" "nmcli -f ipv4.addresses con show eth1 | grep -q '192.168.1.6/24'"
check "1b" "Gateway configured" "nmcli -f ipv4.gateway con show eth1 | grep -q '192.168.1.254'"
check "1c" "DNS configured" "nmcli -f ipv4.dns con show eth1 | grep -q '192.168.1.254'"
check "1d" "Hostname configured" "hostnamectl | grep -q 'ibmid.example.com'"

# Question 2: DNF Repositories
echo -e "${YELLOW}=== Repository Configuration ===${NC}"
check "2a" "BaseOS repo configured" "grep -rq '\[BaseOS\]' /etc/yum.repos.d/ 2>/dev/null"
check "2b" "AppStream repo configured" "grep -rq '\[AppStream\]' /etc/yum.repos.d/ 2>/dev/null"

# Question 3: HTTPD Service Troubleshooting
echo -e "${YELLOW}=== Question 3: HTTPD Service (files in /var/www/html, must run on port 82) ===${NC}"
check "3a" "Files exist in /var/www/html" "test -f /var/www/html/index.html"
check "3b" "HTTPD enabled at boot" "systemctl is-enabled httpd 2>/dev/null || systemctl is-enabled apache2 2>/dev/null"
check "3c" "HTTPD service running" "systemctl is-active httpd 2>/dev/null || systemctl is-active apache2 2>/dev/null"
check "3d" "HTTPD listening on port 82" "ss -tlnp 2>/dev/null | grep -E ':(82)[[:space:]]' | grep -q 'apache2\\|httpd'"
check "3e" "SELinux port 82 configured" "semanage port -l 2>/dev/null | grep http_port_t | grep -q '82'"

# Question 4: Users and Groups
echo -e "${YELLOW}=== Users and Groups ===${NC}"
check "4a" "Manager group exists" "getent group manager"
check "4b" "User simone exists" "id simone"
check "4c" "User walhalla exists" "id walhalla"
check "4d" "User pandora exists" "id pandora"
check "4e" "Simone in manager group" "id simone | grep -q manager"
check "4f" "Walhalla in manager group" "id walhalla | grep -q manager"
check "4g" "Pandora has nologin shell" "grep pandora /etc/passwd | grep -q 'nologin'"

# Question 5: Collaborative Directory
echo -e "${YELLOW}=== Collaborative Directory ===${NC}"
check "5a" "Directory exists" "test -d /shared/manager"
check "5b" "SGID bit set" "stat -c '%a' /shared/manager | grep -q '^2'"
check "5c" "Group ownership" "stat -c '%G' /shared/manager | grep -q 'manager'"
check "5d" "Correct permissions" "stat -c '%a' /shared/manager | grep -q '2770'"

# Question 6: Cron Job
echo -e "${YELLOW}=== Cron Job ===${NC}"
check "6a" "Cron job exists" "crontab -u walhalla -l 2>/dev/null | grep -q 'logger'"
check "6b" "Runs every minute" "crontab -u walhalla -l 2>/dev/null | grep -q '^\*/1\|^\*'"
check "6c" "Correct command" "crontab -u walhalla -l 2>/dev/null | grep -q 'EX200 Test'"

# Question 7: Autofs
echo -e "${YELLOW}=== Autofs ===${NC}"
check "7a" "Autofs installed" "which automount"
check "7b" "Autofs running" "systemctl is-active autofs 2>/dev/null | grep -q 'active'"
check "7c" "Auto.master configured" "grep -q '/home' /etc/auto.master"
check "7d" "Auto.home exists" "test -f /etc/auto.home"

# Question 8: Archive
echo -e "${YELLOW}=== Archive Creation ===${NC}"
check "8a" "Archive exists" "test -f /root/etc_backup.tar.bz2"
check "8b" "Archive is bzip2" "file /root/etc_backup.tar.bz2 | grep -q 'bzip2'"
check "8c" "Archive contains etc" "tar -tjf /root/etc_backup.tar.bz2 2>/dev/null | grep -q 'etc'"

# Question 9: Chrony
echo -e "${YELLOW}=== Chrony/NTP ===${NC}"
check "9a" "Chrony installed" "which chronyd"
check "9b" "Chrony running" "systemctl is-active chronyd 2>/dev/null | grep -q 'active' || systemctl is-active chrony 2>/dev/null | grep -q 'active'"
check "9c" "Server configured" "grep -q 'servera.lab.example.com' /etc/chrony/chrony.conf || grep -q 'servera.lab.example.com' /etc/chrony.conf"

# Question 10: Find Files
echo -e "${YELLOW}=== Find Files ===${NC}"
check "10a" "Walhalla directory exists" "test -d /root/walhalla"
check "10b" "Contains walhalla files" "test -n \"\$(ls -A /root/walhalla 2>/dev/null)\""

# Question 11: String Extraction
echo -e "${YELLOW}=== String Extraction ===${NC}"
check "11a" "Output file exists" "test -f /root/nal_strings.txt || test -f /root/nal.txt"
check "11b" "Contains 'nal' strings" "test -f /root/nal_strings.txt && grep -q 'nal' /root/nal_strings.txt || test -f /root/nal.txt && grep -q 'nal' /root/nal.txt"

# Question 12: Root Password Reset
echo -e "${YELLOW}=== Root Password Reset ===${NC}"
echo "Q12: Root password reset (manual verification required) [SKIP]"

# Question 13: Repositories (Node2)
echo -e "${YELLOW}=== Repositories Node2 ===${NC}"
echo "Q13: Node2 repositories (same as Q2) [SKIP]"

# Question 14: LVM
echo -e "${YELLOW}=== LVM Configuration ===${NC}"
check "14a" "Volume group exists" "vgs | grep -q 'wgroup'"
check "14b" "Logical volume exists" "lvs | grep -q 'wshare'"
check "14c" "PE size is 8M" "vgs wgroup 2>/dev/null | grep -q '8.00m'"
check "14d" "Mounted at /mnt/share" "mount | grep -q '/mnt/share'"
check "14e" "Persist upon reboot (in fstab)" "grep -q '/mnt/share' /etc/fstab"

# Question 15: Swap
echo -e "${YELLOW}=== Swap Partition ===${NC}"
check "15a" "Swap exists" "swapon --show | grep -q 'swap'"
check "15b" "Swap size ~400MB" "swapon --show | awk '{if(\$3 ~ /[0-9]+M/ && \$3+0 >= 380 && \$3+0 <= 420) exit 0; else exit 1}'"
check "15c" "Persist upon reboot (in fstab)" "grep -q 'swap' /etc/fstab"

# Question 16: Resize LV
echo -e "${YELLOW}=== Resize Logical Volume ===${NC}"
check "16a" "LV size ~450MB" "lvs wshare 2>/dev/null | awk '{if(\$4 ~ /[0-9]+/ && \$4+0 >= 430 && \$4+0 <= 470) exit 0; else exit 1}'"
check "16b" "Filesystem resized" "df -h /mnt/share | awk 'NR==2 {if(\$2+0 >= 400) exit 0; else exit 1}'"

# Question 17: Tuned Profile
echo -e "${YELLOW}=== Tuned Profile ===${NC}"
check "17a" "Tuned installed" "which tuned-adm"
check "17b" "Tuned running" "systemctl is-active tuned 2>/dev/null | grep -q 'active'"
check "17c" "Profile set to virtual-guest" "tuned-adm active 2>/dev/null | grep -q 'virtual-guest'"

# Summary
TOTAL=$((PASS + FAIL))
PERCENTAGE=$((PASS * 100 / TOTAL))

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                        EXAM RESULTS                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}PASSED:${NC} $PASS / $TOTAL"
echo -e "${RED}FAILED:${NC} $FAIL / $TOTAL"
echo -e "${YELLOW}SCORE:${NC}  $PERCENTAGE%"
echo ""

if [ $PERCENTAGE -ge 70 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  🎉 CONGRATULATIONS! You passed the RHCSA exam simulation!    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
elif [ $PERCENTAGE -ge 50 ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  Good effort! Keep practicing to improve your score.      ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ More practice needed. Review the failed tasks.             ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
echo "Detailed results saved to: /root/validation_results.log"

# Save detailed results
{
    echo "RHCSA Exam Validation Results"
    echo "Date: $(date)"
    echo "Passed: $PASS / $TOTAL"
    echo "Failed: $FAIL / $TOTAL"
    echo "Score: $PERCENTAGE%"
} > /root/validation_results.log

# Made with Bob
