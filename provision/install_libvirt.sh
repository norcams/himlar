#!/bin/bash
# CentOS 7, Fedora 20/21
sudo yum -y install qemu-kvm libvirt virt-install bridge-utils libvirt-daemon-kvm
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
