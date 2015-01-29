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
puppetfile=false
# We provison Puppetfile if /etc/puppet/modules is empty
[[ -z "$etc_puppet_modules" ]]      && puppetfile=true
# .. or if HIMLAR_PUPPETFILE is set to 'deploy'
[[ $HIMLAR_PUPPETFILE = "deploy" ]] && puppetfile=true
# .. or if puppetmodules.sh is given the 'deploy' parameter
[[ $1 = "deploy" ]]                 && puppetfile=true

# If /opt/himlar/modules contains modules from rsync, use them
[[ -n "$opt_himlar_modules" ]]      && override=true

[[ "$puppetfile" = "true" ]] && provision_from_puppetfile || true
[[ "$override" = "true" ]]   && override_modules          || true

