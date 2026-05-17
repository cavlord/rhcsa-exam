#!/usr/bin/env bash
set -e

LOGFILE="/var/log/rhcsa_simulator.log"
exec > >(tee -a "$LOGFILE") 2>&1

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
  apt-get install -y network-manager >/dev/null 2>&1
  systemctl start NetworkManager
  systemctl enable NetworkManager
  
  # Get active interface
  INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -1)
  
  log "Creating network configuration (interface: $INTERFACE)"
  # Note: nmcli on Ubuntu works similarly to RHEL
  nmcli con mod "$INTERFACE" ipv4.addresses "192.168.1.6/24" || true
  nmcli con mod "$INTERFACE" ipv4.gateway "192.168.1.1" || true
  nmcli con mod "$INTERFACE" ipv4.dns "192.168.1.254" || true
  nmcli con mod "$INTERFACE" ipv4.method manual || true
  
  hostnamectl set-hostname broken.example.com
}

configure_repo() {
  log "Creating repository configuration (Ubuntu uses apt, not dnf)"
  warn "Repository tasks will use apt instead of dnf/yum"
  
  # Create dummy repo files for practice
  mkdir -p /etc/yum.repos.d
  cat >/etc/yum.repos.d/BaseOS.repo <<EOF
[BaseOS]
name=BaseOS
baseurl=http://invalid.example.com/rhel9/BaseOS
enabled=1
gpgcheck=0
EOF

  cat >/etc/yum.repos.d/AppStream.repo <<EOF
[AppStream]
name=AppStream
baseurl=http://invalid.example.com/rhel9/AppStream
enabled=1
gpgcheck=0
EOF
}

configure_httpd_issue() {
  log "Installing and configuring Apache (httpd equivalent)"
  apt-get install -y apache2 >/dev/null 2>&1
  
  mkdir -p /var/www/html
  echo "RHCSA LAB" >/var/www/html/index.html
  
  # Change port to 81 (intentionally wrong)
  sed -i 's/Listen 80/Listen 81/' /etc/apache2/ports.conf
  sed -i 's/:80/:81/' /etc/apache2/sites-available/000-default.conf
  
  # Configure firewall
  apt-get install -y ufw >/dev/null 2>&1
  ufw --force enable
  ufw allow 82/tcp
  
  systemctl enable apache2
  systemctl restart apache2 || true
}

configure_users() {
  log "Creating RHCSA users and groups"
  
  groupadd manager 2>/dev/null || true
  
  useradd -m simone -G manager 2>/dev/null || true
  useradd -m walhalla -G manager 2>/dev/null || true
  useradd -s /usr/sbin/nologin pandora 2>/dev/null || true
  
  echo "simone:indionce" | chpasswd
  echo "walhalla:indionce" | chpasswd
  echo "pandora:indionce" | chpasswd
}

configure_shared_directory() {
  log "Creating broken collaborative directory"
  
  mkdir -p /shared/manager
  chown root:root /shared/manager
  chmod 755 /shared/manager
}

configure_cron() {
  log "Installing and configuring cron"
  apt-get install -y cron >/dev/null 2>&1
  systemctl enable cron
  systemctl start cron
  
  log "Creating incorrect cron job"
  mkdir -p /var/spool/cron/crontabs
  echo '*/5 * * * * logger EX200 Failed' >/var/spool/cron/crontabs/walhalla
  chown walhalla:crontab /var/spool/cron/crontabs/walhalla
  chmod 600 /var/spool/cron/crontabs/walhalla
}

configure_autofs() {
  log "Installing and configuring autofs"
  apt-get install -y autofs nfs-common >/dev/null 2>&1
  
  echo '/home /etc/auto.home' >>/etc/auto.master
  echo 'simone -rw servera.lab.example.com:/wrong/path' >/etc/auto.home
  
  systemctl enable autofs
  systemctl start autofs || true
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
  log "Generating walhalla files"
  
  mkdir -p /opt/labdata
  touch /opt/labdata/w1
  touch /opt/labdata/w2
  chown walhalla:walhalla /opt/labdata/w1 /opt/labdata/w2
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
  tuned-adm profile virtual-guest 2>/dev/null || true
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
}

main "$@"

# Made with Bob
