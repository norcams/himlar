#!/bin/bash

#
# Make sure libvirt and syslinux is installed
#
yum -y install libvirt syslinux

#
# Prepare the tftpboot dir
#
mkdir -p /var/lib/tftpboot \
 /var/lib/tftpboot/pxelinux.cfg \
 /var/lib/tftpboot/boot

cp -f /usr/share/syslinux/memdisk \
      /usr/share/syslinux/menu.c32 \
      /usr/share/syslinux/chain.c32 \
      /usr/share/syslinux/pxelinux.0 \
   /var/lib/tftpboot

#
# TODO: Add pxelinux config as ./pxelinux.cfg/default
#

#
# Create (and start) the network with DHCP and TFTP services enabled
#
virsh net-create himlar-pxe

