#!/usr/bin/env bash
set -Eeuo pipefail

LOGFILE="/var/log/rhcsa_simulator.log"
exec > >(tee -a "$LOGFILE") 2>&1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LAB_HOSTNAME="node1.net11.example.com"
LAB_IP="192.168.1.6/24"
LAB_GW="192.168.1.254"
LAB_DNS="192.168.1.254"
INTERFACE=$(nmcli -t -f DEVICE,STATE device | awk -F: '$2=="connected" {print $1; exit}')

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
  log "Creating incorrect network configuration for troubleshooting"
  nmcli con mod "$INTERFACE" ipv4.addresses "$LAB_IP"
  nmcli con mod "$INTERFACE" ipv4.gateway "192.168.1.1"
  nmcli con mod "$INTERFACE" ipv4.dns "$LAB_DNS"
  nmcli con mod "$INTERFACE" ipv4.method manual
  nmcli con up "$INTERFACE"

  hostnamectl set-hostname broken.example.com
}

configure_repo() {
  log "Creating broken repository files"

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
  log "Installing and intentionally breaking httpd"
  dnf -y install httpd || true
  mkdir -p /var/www/html
  echo "RHCSA LAB" >/var/www/html/index.html

  sed -i 's/^Listen.*/Listen 81/' /etc/httpd/conf/httpd.conf

  firewall-cmd --permanent --add-port=82/tcp || true
  firewall-cmd --reload || true

  systemctl enable httpd
  systemctl restart httpd || true
}

configure_users() {
  log "Creating RHCSA users and groups"

  groupadd manager || true

  useradd simone -G manager || true
  useradd walhalla -G manager || true
  useradd -s /sbin/nologin pandora || true

  echo indionce | passwd --stdin simone
  echo indionce | passwd --stdin walhalla
  echo indionce | passwd --stdin pandora
}

configure_shared_directory() {
  log "Creating broken collaborative directory"

  mkdir -p /shared/manager
  chown root:root /shared/manager
  chmod 755 /shared/manager
}

configure_cron() {
  log "Creating incorrect cron job"

  echo '*/5 * * * * logger EX200 Failed' >/var/spool/cron/walhalla
  chown walhalla:walhalla /var/spool/cron/walhalla
  chmod 600 /var/spool/cron/walhalla
}

configure_autofs() {
  log "Creating broken autofs configuration"

  dnf -y install autofs nfs-utils || true

  echo '/home /etc/auto.home' >>/etc/auto.master
  echo 'simone -rw servera.lab.example.com:/wrong/path' >/etc/auto.home

  systemctl enable --now autofs
}

configure_archive_task() {
  log "Preparing archive challenge"
  mkdir -p /root/archive-task
}

configure_ntp() {
  log "Creating broken chrony configuration"

  dnf -y install chrony || true
  sed -i '/^server/d' /etc/chrony.conf
  echo 'server wrong.example.com iburst' >>/etc/chrony.conf

  systemctl enable --now chronyd
  systemctl restart chronyd || true
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

  parted -s /dev/vdb mklabel gpt || true
  parted -s /dev/vdb mkpart primary 1MiB 800MiB || true

  pvcreate /dev/vdb1 || true
  vgcreate -s 4M wgroup /dev/vdb1 || true
  lvcreate -L 100M -n wronglv wgroup || true

  mkfs.ext4 /dev/wgroup/wronglv

  mkdir -p /mnt/share
  mount /dev/wgroup/wronglv /mnt/share || true
}

configure_swap_task() {
  log "Preparing swap challenge"
}

configure_tuned() {
  log "Installing tuned"

  dnf -y install tuned || true
  systemctl enable --now tuned
  tuned-adm profile virtual-guest || true
}

main() {
  require_root
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

  log "RHCSA simulation environment created"
}

main "$@"
