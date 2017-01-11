#!/bin/bash

if [ ! -f "./passfile" ]; then
  echo "Please create a file called ./passfile with a secure password"
  exit 1
fi


# Generate intermediate key
openssl genrsa -aes256 -passout file:passfile \
        -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

# Generate intermediate cert request
openssl req -config intermediate/openssl.cnf -new -sha256 \
    -passin file:passfile -batch \
    -key intermediate/private/intermediate.key.pem \
    -out intermediate/csr/intermediate.csr.pem

# Sign with root ca
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 -passin file:passfile \
    -in intermediate/csr/intermediate.csr.pem \
    -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem
