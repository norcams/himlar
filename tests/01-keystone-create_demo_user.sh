#!/bin/bash -x
set -o errexit

source ~/openstack.config

openstack osadmin project create --or-show demoproject
openstack osadmin user create --or-show --password himlar0pen demo
openstack osadmin user set --project demoproject demo

openstack osuser user show demo

