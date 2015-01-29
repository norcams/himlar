#!/bin/bash

provision_from_puppetfile()
{
  export PUPPETFILE=/opt/himlar/Puppetfile
  export PUPPETFILE_DIR=/etc/puppet/modules
  /usr/local/bin/r10k --verbose 4 puppetfile purge
  /usr/local/bin/r10k --verbose 4 puppetfile install
}

override_modules()
{
  # remove modules that exists in /opt/himlar/modules
  for m in $modules; do
    echo "WARNING: $m deployed from both Puppetfile and modules/ - using modules/$m"
    rm -rf /etc/puppet/$(echo ${m#/opt/himlar/}) 2>/dev/null
  done
}

etc_puppet_modules="$(ls -d /etc/puppet/modules/*/ 2>/dev/null)"
opt_himlar_modules="$(ls -d /opt/himlar/modules/*/ 2>/dev/null)"

# Default value is to NOT provision from Puppetfile
# We provison Puppetfile if /etc/puppet/modules is empty, if HIMLAR_PUPPETFILE
# is set to 'deploy' or if puppetmodules.sh is given the 'deploy' parameter
puppetfile=false
[[ -z "$etc_puppet_modules" ]]      && puppetfile=true
[[ $HIMLAR_PUPPETFILE = "deploy" ]] && puppetfile=true
[[ $1 = "deploy" ]]                 && puppetfile=true
[[ "$puppetfile" = "true" ]] && provision_from_puppetfile

# If /opt/himlar/modules contains a module deployed via rsync, use that instead
# of the one in /etc/puppet/modules
[[ -z "$opt_himlar_modules" ]] || override_modules

