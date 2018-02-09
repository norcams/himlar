#!/bin/sh

el_repos()
{
  if [ "$#" -ne 1 ]; then
    repo='https://download.iaas.uio.no/uh-iaas/test'
  else
    repo="https://download.iaas.uio.no/uh-iaas/${1}"
  fi

  cat > /etc/yum.repos.d/epel.repo <<- EOM
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
baseurl=$repo/epel
EOM
  cat > /etc/yum.repos.d/puppetlabs.repo <<- EOM
[puppetlabs]
name=Puppet 4 Yum Repo
baseurl=$repo/puppetlabs-PC1/
gpgkey=$repo/puppetlabs-PC1/RPM-GPG-KEY-puppet
enabled=1
gpgcheck=1
EOM
  cat > /etc/yum.repos.d/CentOS-Base.repo <<- EOM
[base]
name=CentOS-\$releasever - Base
baseurl=$repo/centos-base/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-\$releasever - Updates
baseurl=$repo/centos-updates/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras
baseurl=$repo/centos-extras/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOM
}

bootstrap_puppet()
{
  # packages
  if command -v yum >/dev/null 2>&1; then
    # RHEL, CentOS, Fedora
    yum install -y epel-release # to get gpgkey for epel
    el_repos test
    yum clean all
    yum -y update
    yum install -y puppet-agent rubygems git vim inotify-tools
    # Remove default version 3 hiera.yaml
    rm -f /etc/puppetlabs/puppet/hiera.yaml

    gem install -N puppet_forge -v 2.2.6
    gem install -N r10k
  fi

  if command -v apt-get >/dev/null 2>&1; then
    # Assume Debian/CumulusLinux

    # Fix annoying debian thing
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

    wget -O /tmp/puppet-agent_1.10.9-1wheezy_amd64.deb https://download.iaas.uio.no/uh-iaas/aptrepo/pool/main/p/puppet-agent/puppet-agent_1.10.9-1wheezy_amd64.deb
    dpkg -i /tmp/puppet-agent_1.10.9-1wheezy_amd64.deb
    apt-get update
    apt-get -y install git

    gem install --no-ri --no-rdoc r10k
  fi

  # Let puppetrun.sh pick up that we are now in bootstrap mode
  touch /opt/himlar/bootstrap && echo "Created bootstrap marker: /opt/himlar/bootstrap"
}

REPORT_DIR=/opt/puppetlabs/puppet/cache/state

test -f $REPORT_DIR/last_run_report.yaml || bootstrap_puppet
