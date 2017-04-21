#!/bin/bash

function usage {
  echo "This will provision a Cumulus VX appliance"
  echo "./${0} <certname>"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

certname=$1
domain="${certname#*.}"

# Upgrade and install puppet
apt-get update
apt-get -y upgrade
apt-get -y install puppet rsync

FACTER_RUNMODE=bootstrap puppet agent -t --certname=${certname} --server puppet.${domain} --pluginsync --waitforcert 120
puppet agent -t --certname=${certname} --server puppet.${domain}
puppet agent -t
