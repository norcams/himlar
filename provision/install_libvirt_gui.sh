#!/bin/bash
# CentOS 6, 7, Fedora 20/21
sudo yum -y install virt-manager virt-viewer

# Allow users to connect to VMs locally
echo "[libvirt Admin Access]
Identity=unix-group:wheel
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes" > /etc/polkit-1/localauthority/50-local.d/50-iaas.libvirt-access.pkla
