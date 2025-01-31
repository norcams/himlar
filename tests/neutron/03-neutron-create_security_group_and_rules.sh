#!/bin/bash -x
set -o errexit

source ~/keystonerc_admin

# Create a network security group
openstack security group create test_sec_group

# Add a rule which allows incoming SSH
openstack security group rule create --proto tcp --dst-port 22 test_sec_group

# Add a rule which allows incoming ICMP
openstack security group rule create --proto icmp test_sec_group

# Show the newly created security group
openstack security group show test_sec_group --max-width 70
