#!/bin/sh

repo='https://download.iaas.uio.no/uh-iaas/test'

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
