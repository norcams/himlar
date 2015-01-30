#!/bin/bash

if [ -n "$(cat /etc/redhat-release | grep release\ 7)" ]; then
# CentOS 7, Fedora 20/21
  sudo yum -y install qemu-kvm libvirt virt-install bridge-utils libvirt-daemon-kvm
  sudo systemctl start libvirtd
  sudo systemctl enable libvirtd
else
  echo "$rhelversion"
  sudo yum -y install qemu-kvm libvirt virt-install bridge-utils
  chkconfig libvirtd on
  service libvirtd start
fi
