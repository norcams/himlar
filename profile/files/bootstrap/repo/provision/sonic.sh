#!/bin/bash -x

#trap error ERR
exec 2>/root/ZTP-stderror.txt
exec >/root/ZTP-stdout.txt

# to avoid vim users go crazy!
echo 'set mouse -=a' >> /root/.vimrc

#echo "Acquire::ForceIPv4 \"true\";" > /etc/apt/apt.conf.d/99force-ipv4

# Remove edge-core http proxy leftover
if grep 'edge-core' /etc/apt/apt.conf.d/01proxy; then
    rm -f /etc/apt/apt.conf.d/01proxy
fi

# Set time
release=$(cat /etc/debian_version | awk -F'.' '{ print $1 }')
if [ "${release}" -eq 12 ]; then # bookworm
  # chrony installed
  systemctl stop chronyd
  chronyd -q 'server ntp.uio.no iburst'
  /usr/sbin/hwclock --systohc
  systemctl start chronyd
else
  systemctl stop ntp
  ntpd -qg ntp.uio.no
  /usr/sbin/hwclock --systohc
  systemctl start ntp
fi

apt-get update
apt-get install -y lsb-release wget mlocate apt-utils locales-all
updatedb

# use 24h clock
update-locale LC_TIME="en_GB.UTF-8"

# save original config
cp /etc/sonic/config_db.json /etc/sonic/config_db.json.orig

# fix missing platform for cel_ds1000
PLATFORM=$(grep PLATFORM /etc/sonic/sonic-environment | awk -F= '{ print $2 }')
if [ $PLATFORM == "x86_64-cel_ds1000-r0" ] && [ ! "$(dpkg -l platform-modules-ds1000)" ]; then
  dpkg --ignore-depends=linux-image-6.1.0-11-2-amd64-unsigned -i $(locate platform-modules-ds1000_1.0_amd64.deb | tail -n 1)
  sed -i '/Depends: linux-image-6.1.0-11-2-amd64-unsigned/d' /var/lib/dpkg/status
fi

debian_release=$(lsb_release -sc)
wget -O /tmp/puppet7-release-${debian_release}.deb http://apt.puppetlabs.com/puppet7-release-${debian_release}.deb
dpkg -i /tmp/puppet7-release-${debian_release}.deb
apt-get update
apt-get -y install git puppet-agent
systemctl disable --now puppet.service

# Make sure we can load all facts
printf "[agent]\nnumber_of_facts_soft_limit = 2800\ntop_level_facts_soft_limit = 800" >> /etc/puppetlabs/puppet/puppet.conf

CERTNAME=$(getent hosts $(ip -br addr show eth0 | awk '{ print $3 }' | cut -d'/' -f1) | awk '{ print $2}')
PUPPETSERVER=$(echo $CERTNAME | cut -d'-' -f1)-admin-01.$( echo $CERTNAME | cut -d. -f2- )

FACTER_RUNMODE=kickstart /opt/puppetlabs/bin/puppet agent -t --server $PUPPETSERVER --certname $CERTNAME --environment sonic
echo "FACTER_RUNMODE=kickstart /opt/puppetlabs/bin/puppet agent -t --server $PUPPETSERVER --certname $CERTNAME --environment sonic"

# Update /etc/hosts
printf "127.0.0.1\t${CERTNAME}\n" >> /etc/hosts
printf "${CERTNAME}\n" >> /root/certname

# FIXME: workaround for EdgeCore SONiC 202311.3
SONIC_VERSION=$(grep SONIC_VERSION /etc/sonic/sonic-environment | awk -F= '{ print $2 }')
if [ $SONIC_VERSION == "Edgecore-SONiC_202311.3_ec202311_326" ]; then
  /usr/bin/docker exec bgp sh -c "sed -i  '/write_default_zebra_config \/etc\/frr\/frr.conf/c\
    write_default_zebra_config \/etc\/frr\/frr.conf_sonic && touch \/etc\/frr\/frr.conf' /usr/bin/docker_init.sh"
fi

# disable ztp
if [ $(show ztp status | grep Mode | awk -F':' '{ print $2 }' | xargs) == "True" ]; then
  config ztp disable -y
fi
