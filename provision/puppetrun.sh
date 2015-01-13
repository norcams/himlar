#!/bin/bash

# remove modules that are overridden in /opt/himlar/modules
modules="$(ls -d /opt/himlar/modules/*/ 2>/dev/null)"
for m in $modules; do
  echo "$m is overridden in /opt/himlar/modules"
  rm -rf /etc/puppet/$(echo ${m#/opt/himlar/})
done

# Set default certname
certname="vagrant-base-dev.vagrant.local"
# Override with env var if present
certname="${HIMLAR_CERTNAME:-$certname}"
# Override from command line argument $1 if present
certname="${1:-$certname}"
# Write final certname to puppet.conf
puppet config set certname $certname

puppet apply --verbose /etc/puppet/manifests/site.pp

