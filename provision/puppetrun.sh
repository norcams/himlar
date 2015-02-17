#!/bin/bash

# Source command line options as env vars
while [[ $# -gt 0 ]]; do
  case $1 in
    HIMLAR_*=*|FACTER_*=*)
      export $1
      shift
      ;;
    *)
      # unknown
      shift
      ;;
  esac
done

# Set default certname
certname="vagrant-common-dev.vagrant.local"
# Use certname from puppet.conf if present
grep -q certname /etc/puppet/puppet.conf && certname="$(puppet config print certname)"
# Use certname from env var if present
certname="${HIMLAR_CERTNAME:-$certname}"
# Write final certname to puppet.conf
puppet config set --section main certname $certname

puppet apply --verbose --disable_warnings=deprecations --trusted_node_data /etc/puppet/manifests/site.pp
