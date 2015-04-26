#!/bin/bash -x
set -o errexit
source ~/openstack.config
if [ ! -f /tmp/cirros.img ]; then
  curl -#o /tmp/cirros.img http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
fi
# Does not work for some reason?
#osadmin image create "CirrOS test image" --disk-format qcow2 --public --file /tmp/cirros.img

source ~/keystonerc_admin
glance image-create --name "CirrOS test image" \
  --disk-format qcow2 --container-format bare \
  --is-public=True \
  --file /tmp/cirros.img
nova image-list

