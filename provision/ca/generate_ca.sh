#/bin/bash

mkdir private certs

openssl genrsa -out private/ca.key.pem 4096
openssl req -config root.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

openssl x509 -noout -text -in certs/ca.cert.pem

cp -f certs/ca.cert.pem certs/ca-chain.cert.pem
