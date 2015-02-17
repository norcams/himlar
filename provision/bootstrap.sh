#!/bin/bash

provision_puppet()
{
  # packages
  if command -v yum >/dev/null 2>&1; then
    # RHEL, CentOS, Fedora
    rpm -ivh http://fedora.uib.no/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    rpm -ivh http://rdo.fedorapeople.org/rdo-release.rpm
    yum -y update
    yum install -y puppet facter rubygems rubygem-deep_merge \
      rubygem-puppet-lint git vim inotify-tools
  else
    # Assume Debian/CumulusLinux
    apt-get -y install ca-certificates
    wget https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
    dpkg -i puppetlabs-release-wheezy.deb
    apt-get update && apt-get -y install puppet git ruby-deep-merge ruby-puppet-lint
    # FIXME adding wheel group here temporarily
    groupadd --system wheel
  fi

  gem install r10k --no-ri --no-rdoc

  # Temporary solution - download netcf gem and install. Needs some packages to build
  wget -P /tmp/ http://folk.uib.no/edpto/ruby-netcf-0.0.2.gem
  yum install -y netcf-devel gcc ruby-devel
  gem install /tmp/ruby-netcf-0.0.2.gem

  # file locations
  rm -rf /etc/puppet/manifests
  ln -sfT /opt/himlar/manifests /etc/puppet/manifests
  ln -sfT /opt/himlar/hieradata /etc/puppet/hieradata
  ln -sfT /opt/himlar/hiera.yaml /etc/puppet/hiera.yaml

  # settings
  puppet config set --section main basemodulepath /opt/himlar/modules:/etc/puppet/modules
  puppet config set --section main disable_warnings deprecations
  puppet config set --section main trusted_node_data true

  # Let puppetrun.sh pick up that we are now in bootstrap mode
  touch /opt/himlar/bootstrap && echo "Created bootstrap marker: /opt/himlar/bootstrap"
}

command -v puppet >/dev/null 2>&1                  || provision_puppet


