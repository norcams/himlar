#!/bin/bash

provision_puppet()
{
  # packages
  # rpm -ivh http://fedora.uib.no/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
  rpm -ivh http://ftp.lysator.liu.se/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
  rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
  yum -y update
  yum install -y puppet facter rubygems rubygem-deep_merge \
    rubygem-puppet-lint git vim inotify-tools
  gem install r10k --no-ri --no-rdoc

  # file locations
  ln -sfT /opt/himlar/hieradata /etc/puppet/hieradata
  ln -sfT /opt/himlar/manifests /etc/puppet/manifests
  ln -sfT /opt/himlar/hiera.yaml /etc/puppet/hiera.yaml

  # settings
  puppet config set basemodulepath /opt/himlar/modules:/etc/puppet/modules
  puppet config set disable_warnings deprecations
  puppet config set trusted_node_data true
}

provision_puppetfile()
{
    PUPPETFILE=/opt/himlar/Puppetfile \
    PUPPETFILE_DIR=/etc/puppet/modules \
    r10k --verbose 4 puppetfile install
}

export PATH=$PATH:/usr/local/bin
command -v puppet >/dev/null 2>&1                  || provision_puppet
test -n "$(ls -A /etc/puppet/modules 2>/dev/null)" || provision_puppetfile

