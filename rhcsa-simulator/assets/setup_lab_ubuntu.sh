#!/usr/bin/env bash
# Don't exit on error - continue setup even if some commands fail
# set -e

LOGFILE="/var/log/rhcsa_simulator.log"
# Log to file but don't use exec to avoid process issues
# exec > >(tee -a "$LOGFILE") 2>&1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

fail() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

require_root() {
  [[ $EUID -eq 0 ]] || fail "Run as root"
}

configure_network() {
  log "Installing NetworkManager for nmcli"
  apt-get install -y network-manager >/dev/null 2>&1 || true
  systemctl enable NetworkManager 2>/dev/null || true
  systemctl start NetworkManager 2>/dev/null || true
  
  # Create veth pair for practice (more compatible with nmtui than dummy)
  log "Creating virtual network interface 'eth1' for practice"
  ip link add eth1 type veth peer name veth1 2>/dev/null || true
  ip link set eth1 up 2>/dev/null || true
  ip link set veth1 up 2>/dev/null || true
  
  # Make veth interface managed by NetworkManager
  cat > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf <<EOF
[keyfile]
unmanaged-devices=none
EOF
  
  log "Restarting NetworkManager..."
  timeout 10 systemctl restart NetworkManager 2>/dev/null || true
  sleep 2
  log "NetworkManager restarted"
  
  # Create eth1 interface but DON'T configure it - students must configure
  log "Creating eth1 interface (not configured - students must configure)"
  nmcli con add type ethernet ifname eth1 con-name eth1 autoconnect no 2>/dev/null || true
  log "eth1 interface created (no IP/Gateway/DNS configured)"
  
  log "Students should reconfigure:"
  log "  Network (eth1):"
  log "    - IP: 192.168.1.6/24"
  log "    - Gateway: 192.168.1.254"
  log "    - DNS: 192.168.1.254"
  log "  Hostname: node1.net11.example.com"
  log "Can use nmcli or nmtui to configure eth1"
  
  # Set hostname to WRONG value (students must fix)
  hostnamectl set-hostname broken.example.com 2>/dev/null || true
  log "Hostname set to 'broken.example.com' (intentionally wrong)"
  
  # Create systemd service to recreate veth pair on boot
  cat > /etc/systemd/system/veth-eth1.service <<EOF
[Unit]
Description=Create virtual network interface eth1
After=network.target
Before=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/sbin/ip link add eth1 type veth peer name veth1
ExecStart=/sbin/ip link set eth1 up
ExecStart=/sbin/ip link set veth1 up
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
  
  systemctl enable veth-eth1.service 2>/dev/null || true
}

configure_repo() {
  log "Repository configuration - students must create repo files"
  warn "Students must create BaseOS.repo and AppStream.repo in /etc/yum.repos.d/"
  
  # Create directory but don't create repo files - students must create them
  mkdir -p /etc/yum.repos.d
}

configure_httpd_issue() {
  log "Setting up httpd troubleshooting scenario with SELinux"
  log "Question 3: httpd service has files in /var/www/html but not running on port 82"
  
  # Install SELinux packages
  log "Installing SELinux..."
  apt-get install -y selinux-basics selinux-policy-default auditd policycoreutils selinux-utils policycoreutils-python-utils >/dev/null 2>&1
  
  # Install apache2 (httpd equivalent on Ubuntu)
  apt-get install -y apache2 >/dev/null 2>&1
  
  # Create httpd symlink for RHCSA compatibility
  ln -sf /usr/sbin/apache2ctl /usr/sbin/httpd
  ln -sf /lib/systemd/system/apache2.service /etc/systemd/system/httpd.service
  systemctl daemon-reload
  
  # Create files in /var/www/html
  mkdir -p /var/www/html
  echo "RHCSA LAB" >/var/www/html/index.html
  echo "Welcome to RHCSA Exam" >/var/www/html/welcome.html
  
  # Configure httpd to listen on port 82
  sed -i 's/Listen 80/Listen 82/' /etc/apache2/ports.conf
  sed -i 's/:80/:82/' /etc/apache2/sites-available/000-default.conf
  
  # THE PROBLEM: SELinux doesn't allow httpd to bind to port 82
  # Remove port 82 from http_port_t (if SELinux is active)
  if command -v semanage >/dev/null 2>&1; then
    # Port 82 is not in default http_port_t list
    # Students must add it with: semanage port -a -t http_port_t -p tcp 82
    log "SELinux will block port 82 - students must use semanage to allow it"
  fi
  
  # Set correct SELinux context for files (this is OK)
  if command -v restorecon >/dev/null 2>&1; then
    restorecon -Rv /var/www/html 2>/dev/null || true
  fi
  
  # Configure firewall to allow port 82
  apt-get install -y ufw >/dev/null 2>&1
  ufw --force enable
  ufw allow 82/tcp
  
  # Enable SELinux in enforcing mode (will block port 82)
  if [ -f /etc/selinux/config ]; then
    sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config 2>/dev/null || true
  fi
  
  # Enable httpd but DON'T start it (will fail due to SELinux)
  systemctl enable apache2
  systemctl stop apache2 2>/dev/null || true
  
  warn "PROBLEM: SELinux blocks httpd from binding to port 82"
  warn "Students must: semanage port -a -t http_port_t -p tcp 82"
  warn "Then: systemctl restart httpd"
}

configure_users() {
  log "Users and groups - students must create them"
  warn "Students must create users: simone, walhalla, pandora"
  warn "Students must create group: manager"
  # Don't create users/groups - students must create them
}

configure_shared_directory() {
  log "Collaborative directory - students must create it"
  warn "Students must create /shared/manager with correct permissions"
  # Don't create directory - students must create it
}

configure_cron() {
  log "Installing cron service"
  apt-get install -y cron >/dev/null 2>&1
  systemctl enable cron
  systemctl start cron
  
  log "Cron service ready - students must create cron jobs"
  warn "Students must create cron job for user walhalla"
  # Don't create cron job - students must create it
}

configure_autofs() {
  log "Installing autofs"
  apt-get install -y autofs nfs-common >/dev/null 2>&1
  
  systemctl enable autofs
  systemctl start autofs || true
  
  log "Autofs service ready - students must configure auto.master and auto.home"
  warn "Students must configure autofs for user simone"
  # Don't create auto.master and auto.home entries - students must create them
}

configure_archive_task() {
  log "Preparing archive challenge"
  mkdir -p /root/archive-task
}

configure_ntp() {
  log "Installing and configuring chrony"
  apt-get install -y chrony >/dev/null 2>&1
  
  sed -i '/^pool/d' /etc/chrony/chrony.conf
  sed -i '/^server/d' /etc/chrony/chrony.conf
  echo 'server wrong.example.com iburst' >>/etc/chrony/chrony.conf
  
  systemctl enable chrony
  systemctl restart chrony || true
}

configure_find_tasks() {
  log "Preparing find task directory"
  
  mkdir -p /opt/labdata
  # Create some dummy files but not owned by walhalla yet
  touch /opt/labdata/file1
  touch /opt/labdata/file2
  touch /opt/labdata/file3
  
  log "Students must find files owned by user walhalla"
  # Don't create walhalla-owned files - students must create user first
}

configure_lvm() {
  log "Preparing LVM exam tasks"
  
  # Install LVM tools
  apt-get install -y lvm2 >/dev/null 2>&1
  
  # Create a loop device for LVM practice
  dd if=/dev/zero of=/tmp/disk.img bs=1M count=1024 2>/dev/null
  LOOP_DEV=$(losetup -f)
  losetup "$LOOP_DEV" /tmp/disk.img
  
  log "Using loop device: $LOOP_DEV"
  
  pvcreate "$LOOP_DEV" 2>/dev/null || true
  vgcreate -s 4M wgroup "$LOOP_DEV" 2>/dev/null || true
  lvcreate -L 100M -n wronglv wgroup 2>/dev/null || true
  
  mkfs.ext4 /dev/wgroup/wronglv >/dev/null 2>&1
  
  mkdir -p /mnt/share
  mount /dev/wgroup/wronglv /mnt/share || true
}

configure_swap_task() {
  log "Preparing swap challenge"
  # Students will create swap partition
}

configure_tuned() {
  log "Installing tuned"
  apt-get install -y tuned >/dev/null 2>&1
  systemctl enable tuned
  systemctl start tuned
  
  # Set to balanced profile (students must change to virtual-guest)
  log "Setting tuned to balanced profile (wrong profile)"
  tuned-adm profile balanced >/dev/null 2>&1 || true
  
  warn "Students must change tuned profile from balanced to virtual-guest"
}

install_dependencies() {
  log "Installing all required packages..."
  apt-get update -qq
  apt-get install -y \
    network-manager \
    apache2 \
    chrony \
    autofs \
    nfs-common \
    lvm2 \
    cron \
    ufw \
    tuned \
    parted \
    bzip2 \
    tar \
    rsyslog >/dev/null 2>&1
}

main() {
  require_root
  
  log "Starting RHCSA simulation environment setup for Ubuntu"
  log "Note: Some commands adapted from RHEL to Ubuntu equivalents"
  
  install_dependencies
  configure_network
  configure_repo
  configure_httpd_issue
  configure_users
  configure_shared_directory
  configure_cron
  configure_autofs
  configure_archive_task
  configure_ntp
  configure_find_tasks
  configure_lvm
  configure_swap_task
  configure_tuned
  
  log "RHCSA simulation environment created successfully!"
  log "View exam questions: cat /root/questions.txt"
  log "Validate solutions: /root/validate_lab.sh"
  log ""
  log "Ubuntu Adaptations:"
  log "  - httpd → apache2"
  log "  - dnf/yum → apt-get"
  log "  - /dev/vdb → loop device for LVM"
  log "  - Core RHCSA concepts remain the same!"
  
  echo ""
  echo "=========================================="
  echo "Lab environment ready!"
  echo "=========================================="
  echo ""
  echo "Starting RHCSA Exam Menu..."
  sleep 1
  
  # Launch exam menu directly from here
  cd /root
  exec bash /root/rhcsa_exam_menu.sh
}

main "$@"

# Made with Bob
