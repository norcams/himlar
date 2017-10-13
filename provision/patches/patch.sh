#/bin/bash

# Example run ./patch.sh compute

rpm -qa | grep patch- || yum install -y -q patch

component=$1

patches=$(find ${component}/ -type f)

for p in $patches; do
  (cd / && patch -p1) < $p
done
