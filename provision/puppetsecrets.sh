#!/bin/bash

function usage {
  echo "ONLY RUN THIS INSIDE AN OPENSTACK LOCATION!"
  echo ""
  echo "Run as root after the SSH keys are distributed with ansible"
  echo ""
}

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   usage
   exit 1
fi

# Make sure you have the git SSH keys
if [ ! -f /root/.ssh/git_rsa ] || [ ! -f /root/.ssh/git_rsa.pub ]; then
  usage
  exit 1
fi


secrets_dir='/opt/repo/secrets/hieradata'

if [ -d ${secrets_dir}/.git ]; then
  cd ${secrets_dir} && git pull
else
  mkdir -p ${secrets_dir}
  git clone git:hieradata/secrets ${secrets_dir}
fi

rsync -avh ${secrets_dir}/* /opt/himlar/hieradata/secrets/

apachectl graceful
