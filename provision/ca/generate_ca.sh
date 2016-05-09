#/bin/bash

mkdir private certs

openssl genrsa -out private/ca.key.pem 4096
openssl req -config root.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

openssl x509 -noout -text -in certs/ca.cert.pem

cp -f certs/ca.cert.pem certs/ca-chain.cert.pem

echo "
To make the new CA work with your browser remember to edit /etc/hosts
with the following lines on the machine you are running your browser:
----------------------------------------------------------------------
172.31.24.19    access.himlar.local
172.31.24.22    dashboard.himlar.local
"
