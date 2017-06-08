#!/bin/bash

if command -v pkg >/dev/null 2>&1; then
  # Directory prefix for FreeBSD
  PUPPET_PREFIX=/usr/local
  LN_OPTS="-sf"
else
  LN_OPTS="-sfT"
fi

provision_from_puppetfile()
{
  # MIGRATION: remove old symlink if it is present
  test -L /etc/puppet/manifests && rm -f /etc/puppet/manifests
  # ensure file locations are correct
  mkdir -p /etc/puppet/manifests
  ln $LN_OPTS /opt/himlar/manifests/site.pp $PUPPET_PREFIX/etc/puppet/manifests/site.pp
  ln $LN_OPTS /opt/himlar/hieradata $PUPPET_PREFIX/etc/puppet/hieradata
  ln $LN_OPTS /opt/himlar/hiera.yaml $PUPPET_PREFIX/etc/puppet/hiera.yaml
  ln $LN_OPTS /etc/puppet/hiera.yaml $PUPPET_PREFIX/etc/hiera.yaml

  export PUPPETFILE=/opt/himlar/Puppetfile
  export PUPPETFILE_DIR=$PUPPET_PREFIX/etc/puppet/modules
  cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile purge
  cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile install
  # link in profile module after running r10k
  ln -sf /opt/himlar/profile $PUPPET_PREFIX/etc/puppet/modules/
}

override_modules()
{
  # remove modules that exists in /opt/himlar/modules
  for m in $opt_himlar_modules; do
    echo "WARNING: Module $m overrides Puppetfile"
    rm -rf $PUPPET_PREFIX/etc/puppet/$(echo ${m#/opt/himlar/}) 2>/dev/null
  done
}

etc_puppet_modules="$(ls -d $PUPPET_PREFIX/etc/puppet/modules/*/ 2>/dev/null)"
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
