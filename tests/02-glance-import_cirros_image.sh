#!/bin/bash -x
set -o errexit

source ~/keystonerc_admin

# Download CirrOS image if needed
if [ ! -f /tmp/cirros.img ]; then
    curl -o /tmp/cirros.img http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
fi

# Create the image in Glance
openstack image create "CirrOS test image" --disk-format qcow2 --public --file /tmp/cirros.img

# List images
openstack image list

# List images (legacy via Nova API)
nova image-list
