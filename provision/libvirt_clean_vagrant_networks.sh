#!/bin/bash -eux

networks=$(sudo virsh net-list --name | grep -E '^(himlar.*|vagrant-libvirt)$')
echo $networks | xargs -n1 sudo virsh destroy
echo $networks | xargs -n1 sudo virsh net-undefine

