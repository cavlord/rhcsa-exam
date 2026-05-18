#!/usr/bin/env bash
set -Eeuo pipefail

userdel -r simone 2>/dev/null || true
userdel -r walhalla 2>/dev/null || true
userdel -r pandora 2>/dev/null || true
groupdel manager 2>/dev/null || true

rm -rf /shared/manager
rm -f /var/spool/cron/walhalla
rm -f /etc/auto.home
sed -i '/\/home \/etc\/auto.home/d' /etc/auto.master

umount /mnt/share 2>/dev/null || true
lvremove -fy /dev/wgroup/wronglv 2>/dev/null || true
vgremove -fy wgroup 2>/dev/null || true
pvremove -fy /dev/vdb1 2>/dev/null || true

rm -f /etc/yum.repos.d/BaseOS.repo
rm -f /etc/yum.repos.d/AppStream.repo

systemctl stop httpd autofs chronyd tuned 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true

hostnamectl set-hostname localhost.localdomain

rm -rf /opt/labdata
swapoff -a || true

rm -f /var/log/rhcsa_simulator.log

echo "Environment reset complete"

# Made with Bob
