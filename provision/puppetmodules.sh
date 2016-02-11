#!/bin/bash

provision_from_puppetfile()
{
  # ensure file locations are correct
  mkdir -p /etc/puppet/manifests
  ln -sfT /opt/himlar/manifests/site.pp /etc/puppet/manifests/site.pp
  ln -sfT /opt/himlar/hieradata /etc/puppet/hieradata
  ln -sfT /opt/himlar/hiera.yaml /etc/puppet/hiera.yaml
  ln -sfT /etc/puppet/hiera.yaml /etc/hiera.yaml

  export PUPPETFILE=/opt/himlar/Puppetfile
  export PUPPETFILE_DIR=/etc/puppet/modules
  cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile purge
  cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile install
  # link in profile module after running r10k
  ln -sf /opt/himlar/profile /etc/puppet/modules/
}

override_modules()
{
  # remove modules that exists in /opt/himlar/modules
  for m in $opt_himlar_modules; do
    echo "WARNING: Module $m overrides Puppetfile"
    rm -rf /etc/puppet/$(echo ${m#/opt/himlar/}) 2>/dev/null
  done
}

etc_puppet_modules="$(ls -d /etc/puppet/modules/*/ 2>/dev/null)"
opt_himlar_modules="$(ls -d /opt/himlar/modules/*/ 2>/dev/null)"

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

# Default value is to NOT provision from Puppetfile
# We provison Puppetfile if /etc/puppet/modules is empty, if HIMLAR_PUPPETFILE
# is set to 'deploy' or if puppetmodules.sh is given the 'deploy' parameter
puppetfile=false
[[ -z "$etc_puppet_modules" ]]      && puppetfile=true
[[ $HIMLAR_PUPPETFILE = "deploy" ]] && puppetfile=true
[[ "$puppetfile" = "true" ]] && provision_from_puppetfile

# If /opt/himlar/modules contains a module deployed via rsync, use that instead
# of the one in /etc/puppet/modules
[[ -z "$opt_himlar_modules" ]] || override_modules
