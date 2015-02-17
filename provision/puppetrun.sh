#!/bin/bash

set_certname()
{
  # Set default certname
  certname="vagrant-common-dev.vagrant.local"
  # Use certname from puppet.conf if it is present
  grep -q certname /etc/puppet/puppet.conf && certname="$(puppet config print certname)"
  # Override with certname from env var if present
  certname="${HIMLAR_CERTNAME:-$certname}"
  # Write final certname to puppet.conf
  puppet config set --section main certname $certname
}

bootstraprun()
{
  # Run bootstrap if bootstrap file is present
  # If the run exits with 0, remove the marker file
  if [[ -f "/opt/himlar/bootstrap" ]]; then
    FACTER_RUNMODE=bootstrap puppetrun --disable_warnings=deprecations --trusted_node_data
    if [[ $? -eq 0 ]]; then
      echo "Removing bootstrap maker: /opt/himlar/bootstrap"
      rm /opt/himlar/bootstrap
    fi
  fi
}

puppetrun()
{
  puppet apply --verbose "$@" /etc/puppet/manifests/site.pp
}

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

# Set certname
set_certname

# Do bootstrap run if needed
bootstraprun

# Run Puppet
puppetrun
