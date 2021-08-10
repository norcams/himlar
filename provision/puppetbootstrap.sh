#!/bin/sh

# useful for debugging
#set -e

el_repos()
{
  if [ "$#" -ne 1 ]; then
    repo="https://download.iaas.uio.no/nrec/test/${repo_dist}"
  else
    repo="https://download.iaas.uio.no/uh-iaas/${1}/${repo_dist}"
  fi

  wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official

  cat > /etc/yum.repos.d/epel.repo <<- EOM
[epel]
name=Extra Packages for Enterprise Linux ${repo_dist:2} - \$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${repo_dist:2}
baseurl=$repo/epel
EOM
  cat > /etc/yum.repos.d/puppetlabs.repo <<- EOM
[puppetlabs]
name=Puppet 5 Yum Repo
baseurl=$repo/puppetlabs5/
gpgkey=$repo/puppetlabs5/RPM-GPG-KEY-puppet
enabled=1
gpgcheck=1
EOM
  cat > /etc/yum.repos.d/CentOS-Base.repo <<- EOM
[base]
name=CentOS-\$releasever - Base
baseurl=$repo/centos-base/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

[updates]
name=CentOS-\$releasever - Updates
baseurl=$repo/centos-updates/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

[extras]
name=CentOS-\$releasever - Extras
baseurl=$repo/centos-extras/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
EOM
}

bootstrap_puppet()
{
  # packages
  if command -v yum >/dev/null 2>&1; then
    echo "bootstrap puppet ..."
    # RHEL, CentOS, Fedora
    repo_dist=$(uname -r | sed 's/.*\(el[0-9]\).*x86.*/\1/')
    # FIXME
    yum install -y http://download.iaas.uio.no/uh-iaas/repo/${repo_dist}/centos-extras/Packages/epel-release-7-11.noarch.rpm
    # yum install -y epel-release # to get gpgkey for epel
    el_repos test
    yum clean all
    yum -y update
    yum install -y puppet-agent rubygems git vim inotify-tools
    # Remove default version 3 hiera.yaml
    rm -f /etc/puppetlabs/puppet/hiera.yaml

    /opt/puppetlabs/puppet/bin/gem install -N r10k -v 3.4.0
    /opt/puppetlabs/puppet/bin/gem install -N puppet_forge
    ln -s /opt/puppetlabs/puppet/bin/wrapper.sh /opt/puppetlabs/bin/r10k

  fi

  if command -v apt-get >/dev/null 2>&1; then
    # Assume Debian/CumulusLinux

    # Fix annoying debian thing
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
    # New debian version
    if $(/bin/cat /etc/os-release | grep stretch > /dev/null 2>&1); then
      wget -O /tmp/puppetlabs-release-pc1-stretch.deb http://apt.puppetlabs.com/puppetlabs-release-pc1-stretch.deb
      dpkg -i /tmp/puppetlabs-release-pc1-stretch.deb
      apt-get update
      apt-get -y install git rubygems ruby-dev autoconf libtool lsb-release puppet-agent
    else
      wget -O /tmp/puppet-agent_1.10.9-1wheezy_amd64.deb https://download.iaas.uio.no/uh-iaas/aptrepo/pool/main/p/puppet-agent/puppet-agent_1.10.9-1wheezy_amd64.deb
      dpkg -i /tmp/puppet-agent_1.10.9-1wheezy_amd64.deb
      apt-get update
      apt-get -y install git
    fi

    gem install --no-ri --no-rdoc r10k
  fi

  # Let puppetrun.sh pick up that we are now in bootstrap mode
  touch /opt/himlar/bootstrap && echo "Created bootstrap marker: /opt/himlar/bootstrap"
}

REPORT_DIR=/opt/puppetlabs/puppet/cache/state

test -f $REPORT_DIR/last_run_report.yaml || bootstrap_puppet
