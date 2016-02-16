#!/bin/bash

if [ -f "./oauth_client_id" ]; then
  oauth_client_id=$(cat ./oauth_client_id)

fi

if [ -f "./oauth_client_secret" ]; then
  oauth_client_secret=$(cat ./oauth_client_secret)
fi

echo $oauth_client_secret
echo $oauth_client_id

installdir='/var/www/dataporten'

#yum install -y gcc python-devel python-virtualenv

#echo "172.31.24.22  dp.himlar.local" >> /etc/hosts

mkdir ${installdir}
git clone https://github.com/norcams/himlar-dp-prep.git ${installdir}/.
cd ${installdir} && git submodule update --init
virtualenv ${installdir}
cd ${installdir} && bin/python setup.py install
#sed -i s/0.0.0.0/10.4.0.20/g production.ini
#bin/pserve production.ini
