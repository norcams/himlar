#!/bin/bash

# Where are we?
controller_ip=$(facter ipaddress)

case "$1" in
  trd)
    kickstart_hostname="trd-foreman-1.mgmt.iaas.ntnu.no"
    kickstart_certname="trd-foreman-1.iaas.ntnu.no"
    kickstart_ip=10.171.91.5
    kickstart_netmask=255.255.255.0
    kickstart_gw=10.171.91.1
    ;;
  osl)
    kickstart_hostname="osl-foreman-1.iaas.uio.no"
    kickstart_certname="$kickstart_hostname"
    kickstart_ip=129.240.224.101
    kickstart_netmask=255.255.255.224
    kickstart_gw=129.240.224.97
    ;;
  bgo)
    kickstart_hostname="bgo-foreman-1.mgmt.iaas.intern"
    kickstart_certname="bgo-foreman-1.iaas.uib.no"
    kickstart_ip=172.16.32.5
    kickstart_netmask=255.255.248.0
    kickstart_gw=172.16.32.1
    ;;
  dev)
    kickstart_hostname="dev-foreman-1.vagrant.local"
    kickstart_certname="$kickstart_hostname"
    kickstart_ip=10.0.3.5
    kickstart_netmask=255.255.255.0
    kickstart_gw=10.0.3.1
    ;;
  *)
    echo "You need to specify a location."
    exit 1
    ;;
esac


#
# Serve kickstart file
#
pgrep -f "python -m SimpleHTTPServer" | xargs --no-run-if-empty kill
mkdir -p /var/www/html

cp -f /opt/himlar/provision/bootstrap.kickstart /var/www/html/${kickstart_certname}.cfg
sed -i 's/xxxHOSTNAMExxx/'$kickstart_hostname'/' /var/www/html/${kickstart_certname}.cfg
sed -i 's/xxxCERTNAMExxx/'$kickstart_certname'/' /var/www/html/${kickstart_certname}.cfg

cd /var/www/html && python -m SimpleHTTPServer &

#
# Run virt-install to build <loc>-foreman-1
#
virt-install -v \
  -n "${kickstart_certname}" \
  -r 4096 \
  --vcpus 2 \
  --os-variant=rhel7 \
  --accelerate \
  -w network=direct-net \
  --disk /var/lib/libvirt/images/${kickstart_certname}.img,size=10 --force \
  -l http://centos.uib.no/7.0.1406/os/x86_64/ \
  --graphics spice,listen=${controller_ip} --noautoconsole \
  -x "ks=http://${controller_ip}:8000/${kickstart_certname}.cfg network ks.sendmac net.ifnames=0 ip=${kickstart_ip} netmask=${kickstart_netmask} gateway=${kickstart_gw} dns=8.8.8.8" \
  &

