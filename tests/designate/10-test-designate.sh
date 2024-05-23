#!/bin/bash -x
set -o errexit

# Make sure we're the demo user
source ~/keystonerc_demo

# Make sure designate cli is installed
rpm -q --quiet python3-designateclient || yum -y install python3-designateclient

# Output tip
echo "Remember to log into the designate node and run:"
echo "  designate-manage pool update --file /etc/designate/pools.yaml"

# Create zone
openstack zone create --email foo@bar.com example.com.

# List zones
openstack zone list

# Create A records
openstack recordset create example.com. test01 --type A --record 10.0.0.1
openstack recordset create example.com. test02 --type A --record 10.0.0.2
openstack recordset create example.com. test03 --type A --record 10.0.0.3
openstack recordset create example.com. test04 --type A --record 10.0.0.4

# Create AAAA records
openstack recordset create example.com. test01 --type AAAA --record fd32:100:200:300::11
openstack recordset create example.com. test02 --type AAAA --record fd32:100:200:300::12
openstack recordset create example.com. test03 --type AAAA --record fd32:100:200:300::13
openstack recordset create example.com. test04 --type AAAA --record fd32:100:200:300::14

# Create CNAME
openstack recordset create example.com. www --type CNAME --record test01.example.com.

# List records
openstack recordset list example.com.

# Look up records
host test01.example.com 172.31.8.16
host test02.example.com 172.31.8.16
host test03.example.com 172.31.8.16
host test04.example.com 172.31.8.16
host www.example.com 172.31.8.16
