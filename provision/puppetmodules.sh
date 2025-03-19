#!/bin/bash

LN_OPTS="-sfT"
CODE_PATH=/etc/puppetlabs/code
R10K=/opt/puppetlabs/bin/r10k

#etc_puppet_modules="$(ls -d $CODE_PATH/modules/*/ 2>/dev/null)"
#opt_himlar_modules="$(ls -d /opt/himlar/modules/*/ 2>/dev/null)"
#host=$(hostname)
#environment=${host%%-*}     # assumes standard name convention with environment as first part (in front of a '-')

provision_environment()
{
  PUPPET_ENV="${HIMLAR_PUPPET_ENV:-production}"
  ENV_PATH=environments/$PUPPET_ENV
  if [ ! -f $CODE_PATH/$ENV_PATH/manifests/site.pp ]; then
    mkdir -p $CODE_PATH/$ENV_PATH/manifests
    mkdir -p $CODE_PATH/$ENV_PATH/modules
    ln $LN_OPTS /opt/himlar/manifests/site.pp $CODE_PATH/$ENV_PATH/manifests/site.pp
    rm -rf $CODE_PATH/$ENV_PATH/hieradata
    ln $LN_OPTS /opt/himlar/hieradata $CODE_PATH/$ENV_PATH/hieradata
    ln $LN_OPTS /opt/himlar/hiera.yaml $CODE_PATH/$ENV_PATH/hiera.yaml
  fi
}

provision_common_modules()
{
  # deploy all shared modules to $CODE_PATH/modules
  cd /opt/himlar && $R10K --verbose 4 puppetfile purge --moduledir $CODE_PATH/modules \
      --puppetfile /opt/himlar/Puppetfile
  cd /opt/himlar && $R10K --verbose 4 puppetfile install --moduledir $CODE_PATH/modules \
      --puppetfile /opt/himlar/Puppetfile --force

  # link in profile module after running r10k
  ln -sf /opt/himlar/profile $CODE_PATH/modules/
}

provision_env_modules()
{
  # depoly puppet environment only modules if env has Puppetfile
  if [ -f /opt/himlar/puppetfiles/$PUPPET_ENV.Puppetfile ]; then
    cd /opt/himlar && $R10K --verbose 4 puppetfile purge --moduledir $CODE_PATH/$ENV_PATH/modules \
        --puppetfile /opt/himlar/puppetfiles/$PUPPET_ENV.Puppetfile
    cd /opt/himlar && $R10K --verbose 4 puppetfile install --moduledir $CODE_PATH/$ENV_PATH/modules \
        --puppetfile /opt/himlar/puppetfiles/$PUPPET_ENV.Puppetfile --force
    if [[ ! -z $HIMLAR_VAGRANT ]] && [[ $HIMLAR_VAGRANT == "true" ]]; then
      printf "modulepath = \$basemodulepath\n" > $CODE_PATH/$ENV_PATH/environment.conf
    fi
  fi
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

provision_environment

# Do a full deploy of common modules if first time or when redeploy
[[ $HIMLAR_DEPLOYMENT == "redeploy" ]] && commondeploy=true
[[ -z "$(ls -A $CODE_PATH/modules)" ]] && commondeploy=true
[[ "${commondeploy}" == "true" ]] && provision_common_modules

[[ $HIMLAR_DEPLOYMENT == "redeploy" ]] && envdeploy=true
[[ -z "$(ls -A $CODE_PATH/$ENV_PATH/modules)" ]] && envdeploy=true
[[ "$envdeploy" == "true" ]] && provision_env_modules

# Make sure we exit 0 at the end
exit 0
