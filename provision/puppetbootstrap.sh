#!/bin/sh

# useful for debugging
#set -e

el_repos()
{
  repo="https://download.iaas.uio.no/nrec/${repo_env}/${repo_dist}"

  cat > /etc/yum.repos.d/epel.repo <<- EOM
[epel]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${repo_dist:2}
baseurl=$repo/epel
EOM
  cat > /etc/yum.repos.d/puppetlabs.repo <<- EOM
[puppetlabs]
name=Puppet 6 Yum Repo
baseurl=$repo/puppetlabs6/
gpgkey=$repo/puppetlabs6/RPM-GPG-KEY-puppet-20250406
enabled=1
gpgcheck=1
EOM
}

el8_repos()
{

  repo="https://download.iaas.uio.no/nrec/${repo_env}/${repo_dist}"

  # we do not use epel modular
  rm -f /etc/yum.repos.d/epel-modular.repo

  # Add our epel mirror
  cat > /etc/yum.repos.d/epel.repo <<- EOM
[epel]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${repo_dist:2}
baseurl=$repo/epel
EOM

  # Add our puppetlabs mirror
cat > /etc/yum.repos.d/puppetlabs.repo <<- EOM
[puppetlabs]
name=Puppet 7 Yum Repo
baseurl=$repo/puppetlabs7/
gpgkey=$repo/puppetlabs7/RPM-GPG-KEY-puppet-20250406
enabled=1
gpgcheck=1
EOM

}

bootstrap_puppet()
{

  repo_dist=$(uname -r | sed 's/.*\(el[0-9]\).*x86.*/\1/')

  # setup dnf/yum
  if command -v dnf >/dev/null 2>&1; then
    echo "bootstrap puppet for el8..."
    dnf install --refresh -y epel-release # to get gpgkey for epel
    el8_repos
    dnf -y upgrade
    dnf install -y puppet-agent git-core vim network-scripts gcc make

    #r10k bug: https://github.com/puppetlabs/r10k/issues/1370
    /opt/puppetlabs/puppet/bin/gem install -N faraday-net_http -v 3.0.2
    /opt/puppetlabs/puppet/bin/gem install -N faraday -v 2.8.1

    /opt/puppetlabs/puppet/bin/gem install -N r10k
    # this is need one puppetmaster for some modules
    # in vagrant we will need this on all nodes
    /opt/puppetlabs/puppet/bin/gem install -N toml-rb

    # The r10k path must be the same as in puppetmodules.sh
    ln -sf /opt/puppetlabs/puppet/bin/r10k /opt/puppetlabs/bin/r10k

  elif command -v yum >/dev/null 2>&1; then
    echo "bootstrap puppet for el7..."
    yum install -y epel-release # to get gpgkey for epel
    el_repos test
    yum clean all
    yum -y update
    yum install -y puppet-agent git vim gcc
    # Remove default version 3 hiera.yaml
    rm -f /etc/puppetlabs/puppet/hiera.yaml
    /opt/puppetlabs/puppet/bin/gem install -N cri -v 2.15.11
    /opt/puppetlabs/puppet/bin/gem install -N puppet_forge -v 3.2.0
    /opt/puppetlabs/puppet/bin/gem install -N r10k -v 3.16.0
    ln -sf /opt/puppetlabs/puppet/bin/wrapper.sh /opt/puppetlabs/bin/r10k

  fi

  if command -v apt-get >/dev/null 2>&1; then

    # Assume Debian/CumulusLinux
    debian_release=$(lsb_release -c | awk '{ print $2 }')
    wget -O /tmp/puppet6-release-${debian_release}.deb http://apt.puppetlabs.com/puppet6-release-${debian_release}.deb
    dpkg -i /tmp/puppet6-release-${debian_release}.deb
    apt-get update
    apt-get -y install git puppet-agent

    # Remove default version 3 hiera.yaml
    rm -f /etc/puppetlabs/puppet/hiera.yaml

    /opt/puppetlabs/puppet/bin/gem install -N puppet_forge -v 3.2.0
    /opt/puppetlabs/puppet/bin/gem install -N r10k
    ln -sf /opt/puppetlabs/puppet/bin/wrapper.sh /opt/puppetlabs/bin/r10k

  fi

  # Let puppetrun.sh pick up that we are now in bootstrap mode
  touch /opt/himlar/bootstrap && echo "Created bootstrap marker: /opt/himlar/bootstrap"
}

REPORT_DIR=/opt/puppetlabs/puppet/cache/state

# test repos are used if we do not provide repo env or is running in vagrant
# in vagrant this script is called with multiple args
#if $(hostname) == *"vagrant"* ; then
#  repo_env='test'
#elif $# -e 1 ; then
#  repo_env=$1
#else
repo_env='test'
#fi

test -f $REPORT_DIR/last_run_report.yaml || bootstrap_puppet
