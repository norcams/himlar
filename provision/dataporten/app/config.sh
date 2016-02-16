#!/bin/bash

installdir='/var/www/dataporten'
host='172.31.24.22'
master='172.31.24.20'
admin_pw='admin_pass'


if [ -f "./oauth_client_id" ]; then
  oauth_client_id=$(cat ./oauth_client_id)
  sed -i "s/oauth_client_id = nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn/oauth_client_id = ${oauth_client_id}/g" ${installdir}/production.ini
else
  echo "WARNING: Missing ./oauth_client_id"
fi

if [ -f "./oauth_client_secret" ]; then
  oauth_client_secret=$(cat ./oauth_client_secret)
  sed -i "s/oauth_client_secret = nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn/oauth_client_secret = ${oauth_client_secret}/g" ${installdir}/production.ini
else
  echo "WARNING: Missing ./oauth_client_secret"
fi

sed -i "s/host = 0.0.0.0/host = ${host}/g" ${installdir}/production.ini
sed -i "s/10.0.3.11/${master}/g" ${installdir}/production.ini
sed -i "s/admin_pw = xxxxxxxx/admin_pw = ${admin_pw}/g" ${installdir}/production.ini

echo "To start application:"
echo "# cd ${installdir}"
echo "# bin/pserve production.ini"
