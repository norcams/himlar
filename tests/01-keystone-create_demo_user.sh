#!/bin/bash -x
set -o errexit

source ~/openstack.config

osadmin project create --or-show demoproject
osadmin user create --or-show --password himlar0pen demo
osadmin user set --project demoproject demo

osuser user show demo

