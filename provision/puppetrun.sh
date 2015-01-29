#!/bin/bash

# Set default certname
certname="vagrant-common-dev.vagrant.local"
# Use certname from puppet.conf if present
grep -q certname /etc/puppet/puppet.conf && certname="$(puppet config print certname)"
# Use certname from env var if present
certname="${HIMLAR_CERTNAME:-$certname}"
# Use certname from command line argument if present
certname="${1:-$certname}"
# Write final certname to puppet.conf
puppet config set certname $certname

puppet apply --verbose /etc/puppet/manifests/site.pp
