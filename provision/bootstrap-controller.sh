#!/bin/bash

case "$1" in
  trd)
    kickstart_hostname="trd-controller-1.mgmt.iaas.ntnu.no"
    kickstart_certname="trd-controller-1.iaas.ntnu.no"
    kickstart_server=10.171.91.3
    kickstart_netmask=255.255.255.0
    kickstart_range_start=10.171.91.200
    kickstart_range_end=10.171.91.254
    ;;
  osl)
    kickstart_hostname="osl-controller-1.iaas.uio.no"
    kickstart_certname="$kickstart_hostname"
    kickstart_server=129.240.224.102
    kickstart_netmask=255.255.255.224
    kickstart_range_start=129.240.224.115
    kickstart_range_end=129.240.224.126
    ;;
  bgo)
    kickstart_hostname="bgo-controller-1.mgmt.iaas.intern"
    kickstart_certname="bgo-controller-1.iaas.uib.no"
    kickstart_server=172.16.32.6
    kickstart_netmask=255.255.248.0
    kickstart_range_start=172.16.32.200
    kickstart_range_end=172.16.32.254
    ;;
  *)
    kickstart_hostname="dev-controller-1.vagrant.local"
    kickstart_certname="$kickstart_hostname"
    kickstart_server=10.0.3.6
    kickstart_netmask=255.255.255.0
    kickstart_range_start=10.0.3.200
    kickstart_range_end=10.0.3.254
    ;;
esac


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
echo "
default linux
label linux
kernel boot/vmlinuz
append initrd=boot/initrd.img ks=http://kickstart:8000/${kickstart_certname}.cfg network ks.sendmac net.ifnames=0
IPAPPEND 2
" > /var/lib/tftpboot/pxelinux.cfg/default

#
# Create (and start) the network with DHCP and TFTP services enabled
#
cp -f /opt/himlar/provision/bootstrap-controller.xml /tmp
sed -i 's/xxxIPxxx/'$kickstart_server'/' /tmp/bootstrap-controller.xml
sed -i 's/xxxNETMASKxxx/'$kickstart_netmask'/' /tmp/bootstrap-controller.xml
sed -i 's/xxxRANGE_STARTxxx/'$kickstart_range_start'/' /tmp/bootstrap-controller.xml
sed -i 's/xxxRANGE_ENDxxx/'$kickstart_range_end'/' /tmp/bootstrap-controller.xml
virsh net-list | grep bootstrap-controller && virsh net-destroy bootstrap-controller
virsh net-create /tmp/bootstrap-controller.xml

#
# Serve kickstart file
#
pgrep -f "python -m SimpleHTTPServer" | xargs --no-run-if-empty kill
mkdir -p /var/www/html

cp -f /opt/himlar/provision/bootstrap.kickstart /var/www/html/${kickstart_certname}.cfg
sed -i 's/xxxHOSTNAMExxx/'$kickstart_hostname'/' /var/www/html/${kickstart_certname}.cfg
sed -i 's/xxxCERTNAMExxx/'$kickstart_certname'/' /var/www/html/${kickstart_certname}.cfg

cd /var/www/html && python -m SimpleHTTPServer &

