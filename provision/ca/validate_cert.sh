#/bin/bash

ca_dir='/opt/himlar/provision/ca'
horizon='192.168.0.254'
CAfile="${ca_dir}/certs/ca.cert.pem"

if [ ! -d "${ca_dir}" ]; then
  echo "Missing ${ca_dir}! Be sure to run this inside vagrant."
  exit 1
fi

export CURL_CA_BUNDLE=${CAfile}

echo "" | openssl s_client -connect ${horizon}:5000 -CAfile ${CAfile}

echo "openssl x509 -text -noout -in  /etc/pki/tls/certs/vagrant.crt"
echo "openssl req -text -noout -verify -in /etc/pki/tls/certs/vagrant.csr"
echo "curl -I https://dashboard.himlar.local:5000/v3"
echo "curl -I https://dashboard.himlar.local"
