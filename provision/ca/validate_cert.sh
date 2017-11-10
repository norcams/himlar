#!/bin/bash

host='https://api.vagrant.iaas.intern:5000/v3'
ca_dir='/opt/himlar/provision/ca'
api='192.168.0.250'
CAfile="${ca_dir}/certs/ca.cert.pem"

if [ ! -d "${ca_dir}" ]; then
  echo "Missing ${ca_dir}! Be sure to run this inside vagrant."
  exit 1
fi


echo "" | openssl s_client -connect ${api}:5000 -CAfile ${CAfile}
echo "----"
curl -I --cacert ${CAfile} ${host}
echo "----"
echo "To validate local cert files and check CSR user these commands:"
echo "openssl x509 -text -noout -in  /etc/pki/tls/certs/<file>.crt"
echo "openssl req -text -noout -verify -in /etc/pki/tls/certs/<file>.csr"
