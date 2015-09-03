#!/bin/bash -xv
if [ ! -f /tmp/centos.img ]; then
  curl -#o /tmp/centos.img http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
fi
# Does not work for some reason?
openstack osadmin image create "CentOS test image" --disk-format qcow2 --public --file /tmp/centos.img

source ~/keystonerc_admin
glance \
  --verbose --debug \
  image-create --name "CentOS test image" \
  --disk-format qcow2 --container-format bare \
  --is-public=True \
  --file /tmp/centos.img
nova image-list

