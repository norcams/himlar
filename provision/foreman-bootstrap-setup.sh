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
# Get the installer initrd and kernel
#
curl -f -L -C - -o /var/lib/tftpboot/boot/initrd.img \
  http://centos.uib.no/7.0.1406/os/x86_64/images/pxeboot/initrd.img
curl -f -L -C - -o /var/lib/tftpboot/boot/vmlinuz \
  http://centos.uib.no/7.0.1406/os/x86_64/images/pxeboot/vmlinuz

#
# Write pxelinux.cfg/default
#
echo '
default linux
label linux
kernel boot/vmlinuz
append initrd=boot/initrd.img ks=http://kickstart:8000/ks.cfg network ks.sendmac net.ifnames=0
IPAPPEND 2
' > /var/lib/tftpboot/pxelinux.cfg/default

#
# Create (and start) the network with DHCP and TFTP services enabled
#
virsh net-list | grep foreman-bootstrap && virsh net-destroy foreman-bootstrap
virsh net-create foreman-bootstrap.xml

#
# Serve kickstart file
#
pgrep -f "python -m SimpleHTTPServer" | xargs --no-run-if-empty kill
mkdir -p /var/www/html

case "$1" in
  trd)
    kickstart_hostname="trd-controller-1.mgmt.iaas.ntnu.no"
    kickstart_certname="trd-controller-1.iaas.ntnu.no"
    ;;
  osl)
    kickstart_hostname="osl-controller-1.iaas.uio.no"
    kickstart_certname="$kickstart_hostname"
    ;;
  bgo)
    kickstart_hostname="bgo-controller-1.mgmt.iaas.intern"
    kickstart_certname="bgo-controller-1.iaas.uib.no"
    ;;
  *)
    kickstart_hostname="dev-controler-1.vagrant.local"
    kickstart_certname="$kickstart_hostname"
    ;;
esac

cp -f foreman-bootstrap.kickstart /var/www/html/ks.cfg
sed -i 's/xxxHOSTNAMExxx/'$kickstart_hostname'/' /var/www/html/ks.cfg
sed -i 's/xxxCERTNAMExxx/'$kickstart_certname'/' /var/www/html/ks.cfg

cd /var/www/html && python -m SimpleHTTPServer &

