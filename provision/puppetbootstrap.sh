#!/bin/bash

bootstrap_puppet()
{
  # packages
  if command -v yum >/dev/null 2>&1; then
    # RHEL, CentOS, Fedora
    rpm -ivh http://ftp.uninett.no/linux/epel/epel-release-latest-7.noarch.rpm
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
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

  # Let puppetrun.sh pick up that we are now in bootstrap mode
  touch /opt/himlar/bootstrap && echo "Created bootstrap marker: /opt/himlar/bootstrap"
}

grep --quiet --silent profile /var/lib/puppet/state/last_run_report.yaml || bootstrap_puppet
