#!/bin/bash -x
set -o errexit

source ~/keystonerc_admin

neutron net-create testnet
neutron subnet-create --name testsubnet testnet 10.200.0.0/24

# NEW:
## Create a network "testnet"
#openstack network create testnet
#
## Create a subnet "testsubnet" which is a member of "testnet"
#neutron subnet-create --name testsubnet testnet 10.200.0.0/24
