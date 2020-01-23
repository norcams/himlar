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
puppet_bin='/opt/puppetlabs/bin/puppet'

# Clean up old puppet
apt-get -y purge puppet-agent
rm -rf /opt/puppetlabs
rm -rf /opt/puppetlabs

# Upgrade
apt-get update
apt-get -y upgrade

# Install puppet5 for jessie (cumulus 3.7.x)
wget -O puppet5-release-jessie.deb http://apt.puppetlabs.com/puppet5-release-jessie.deb
dpkg -i puppet5-release-jessie.deb
apt-get update

apt-get -y install puppet-agent

FACTER_RUNMODE=bootstrap ${puppet_bin} agent -t --certname=${certname} --server puppet.${domain} --waitforcert 120
${puppet_bin} agent -t
