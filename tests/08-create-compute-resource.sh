#!/bin/bash -vx
PREFIX=$(hostname | sed -e 's/-.*$//')
DOMAIN=$(hostname -f | sed -e 's/^[a-z0-9-]*\.//')

hammer compute-resource list
hammer compute-resource create --provider Libvirt  --url qemu://${PREFIX}-controller-02.${DOMAIN}/system --name ${PREFIX}-controller-02
hammer compute-resource list
