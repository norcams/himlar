#!/bin/bash

if [ ! -f "./passfile" ]; then
  echo "Please create a file called ./passfile with a secure password"
  exit 1
fi

mkdir -p certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Create CA key
openssl genrsa -aes256 -passout file:passfile -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# Create CA cert
openssl req -config openssl.cnf \
      -key private/ca.key.pem -passin file:passfile -batch \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

chmod 444 certs/ca.cert.pem

./bootstrap_intermediate.sh
./create_intermediate.sh
./create_cachain.sh
