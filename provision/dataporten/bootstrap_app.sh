#!/bin/bash

## find installation type
if [ $# -ne 1 ]; then
  echo "Warning: no location provided. Using defaults for vagrant. To change run"
  echo "./bootstrap_app.sh osl"
  type='develop'
else
  # type should be install when not run in vagrant
  type='install'
fi

installdir='/opt/dpapp'
packages='gcc python-devel python-virtualenv httpd'
user="dpapp"

yum install -y ${packages}

if [ -d "${installdir}" ]; then
  rm -Rf ${installdir}
fi

mkdir ${installdir}
chown ${user} ${installdir}
git clone https://github.com/raykrist/himlar-dp-prep.git ${installdir}/.
cd ${installdir} && git submodule update --init
virtualenv ${installdir}
cd ${installdir} && bin/python setup.py ${type}
