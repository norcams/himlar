#!/bin/bash

set_certname()
{
  # Set default certname
  certname="vagrant-base-dev.himlar.local"
  # Use certname from puppet.conf if it is present
  grep -q certname /etc/puppetlabs/puppet/puppet.conf && certname="$(/opt/puppetlabs/puppet/bin/puppet config print certname)"
  # Override with certname from env var if present
  certname="${HIMLAR_CERTNAME:-$certname}"
}

bootstraprun()
{
  # Run bootstrap if bootstrap file is present
  # If the run exits with 0, remove the marker file
  if [[ -f "/opt/himlar/bootstrap" ]]; then
    FACTER_RUNMODE=bootstrap puppetrun
    if [[ $? -eq 0 ]]; then
      echo "puppetrun.sh: $certname bootstrap finished"
      rm -fv /opt/himlar/bootstrap
    fi
  fi
}

puppetrun()
{
  /opt/puppetlabs/puppet/bin/puppet apply --verbose --show_diff \
    --certname $certname \
    --write-catalog-summary \
    --basemodulepath /opt/himlar/modules:/etc/puppetlabs/code/modules \
    ${p_args[*]} \
    /etc/puppetlabs/code/environments/production/manifests/site.pp
}

# Source command line options as env vars
while [[ $# -gt 0 ]]; do
  case $1 in
    HIMLAR_*=*|FACTER_*=*)
      export $1
      shift
      ;;
    *)
      # Passing through to Puppet
      p_args+=("$1")
      shift
      ;;
  esac
done

# Set certname
set_certname

# Do bootstrap run if needed
if [[ ! $FACTER_is_installer == "true" ]]; then
    bootstraprun
fi

# Run Puppet
puppetrun
