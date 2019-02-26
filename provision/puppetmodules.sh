#!/bin/bash

LN_OPTS="-sfT"
CODE_PATH=/etc/puppetlabs/code
ENV_PATH=environments/production

etc_puppet_modules="$(ls -d $CODE_PATH/modules/*/ 2>/dev/null)"
opt_himlar_modules="$(ls -d /opt/himlar/modules/*/ 2>/dev/null)"
host=$(hostname)
environment=${host%%-*}     # assumes standard name convention with environment as first part (in front of a '-')

provision_from_puppetfile()
{
  ln $LN_OPTS /opt/himlar/manifests/site.pp $CODE_PATH/$ENV_PATH/manifests/site.pp
  rm -rf $CODE_PATH/$ENV_PATH/hieradata
  ln $LN_OPTS /opt/himlar/hieradata $CODE_PATH/$ENV_PATH/hieradata
  ln $LN_OPTS /opt/himlar/hiera.yaml $CODE_PATH/$ENV_PATH/hiera.yaml
  if [[ ! "${environment}x" == "vagrantx" ]]; then force="--force"; fi

  cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile purge
  cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile install --moduledir $CODE_PATH/modules --puppetfile /opt/himlar/Puppetfile ${force}
  # link in profile module after running r10k
  ln -sf /opt/himlar/profile $CODE_PATH/modules/
}

override_modules()
{
  # remove modules that exists in /opt/himlar/modules
  for m in $opt_himlar_modules; do
    echo "WARNING: Module $m overrides Puppetfile"
    rm -rf $CODE_PATH/$(echo ${m#/opt/himlar/}) 2>/dev/null
  done
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

# Default value is to NOT provision from Puppetfile
# We provison Puppetfile if /etc/puppet/modules is empty, if HIMLAR_PUPPETFILE
# is set to 'deploy' or if puppetmodules.sh is given the 'deploy' parameter
puppetfile=false
[[ -z "$etc_puppet_modules" ]]      && puppetfile=true
[[ $HIMLAR_PUPPETFILE = "deploy" ]] && puppetfile=true
[[ "$puppetfile" = "true" ]] && provision_from_puppetfile

# only consider module overriding from himlar if in environment 'vagrant' (only for development)
if [[ "${environment}x" == "vagrantx" ]]; then
  # If /opt/himlar/modules contains a module deployed via rsync, use that instead
  # of the one in /etc/puppet/modules
  [[ -z "$opt_himlar_modules" ]] || override_modules
fi
