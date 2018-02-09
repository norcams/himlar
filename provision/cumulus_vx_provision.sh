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
puppet_bin=''

# Clean up old puppet
apt-get -y purge puppet facter ruby-rgen puppet-common hiera
rm -rf /var/lib/puppet
rm -rf /etc/puppet

# Upgrade
apt-get update
apt-get -y upgrade

# Install puppet repo PC1
wget -O /tmp/puppetlabs-release-pc1-wheezy.deb http://apt.puppetlabs.com/puppetlabs-release-pc1-wheezy.deb
dpkg -i /tmp/puppetlabs-release-pc1-wheezy.deb
apt-get update

apt-get -y install puppet-agent

FACTER_RUNMODE=bootstrap ${puppet_bin} agent -t --certname=${certname} --server puppet.${domain} --waitforcert 120
${puppet_bin} agent -t
