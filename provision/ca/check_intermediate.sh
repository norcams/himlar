#!/bin/bash

openssl x509 -noout -text \
        -in intermediate/certs/intermediate.cert.pem

openssl verify -CAfile certs/ca.cert.pem \
        intermediate/certs/intermediate.cert.pem
