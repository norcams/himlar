#!/bin/bash

if command -v pkg >/dev/null 2>&1; then
  # Directory prefix for FreeBSD
  PUPPET_PREFIX=/usr/local
  # FreeBSD needs extra symlink
  ln -s /usr/local/etc/puppet/hieradata/ /etc/puppet/hieradata
fi

set_certname()
{
  # Set default certname
  certname="vagrant-base-dev.himlar.local"
  # Use certname from puppet.conf if it is present
  grep -q certname $PUPPET_PREFIX/etc/puppet/puppet.conf && certname="$(puppet config print certname)"
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

  # Manually restart FreeBSD interfaces
  if command -v pkg >/dev/null 2>&1; then
    service netif restart vtnet1
    service netif restart vtnet2
    service netif restart tap0
  fi
}

puppetrun()
{
  puppet apply --verbose --show_diff \
    --certname $certname \
    --disable_warnings=deprecations \
    --trusted_node_data \
    --no-stringify_facts \
    --write-catalog-summary \
    --basemodulepath /opt/himlar/modules:$PUPPET_PREFIX/etc/puppet/modules --verbose \
    ${p_args[*]} \
    $PUPPET_PREFIX/etc/puppet/manifests/site.pp
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
bootstraprun

# Run Puppet
puppetrun
