#!/bin/bash -x
#set -o errexit

source ~/openrc

os_demo_project_name=demoproject
os_demo_username=demo
os_demo_password=himlar0pen

# Create a demo project
openstack --insecure project create --or-show $os_demo_project_name

# Create a demo user
openstack --insecure user create --or-show --password "$os_demo_password" $os_demo_username

# Associate the demo user with the demo project
openstack --insecure user set --project $os_demo_project_name $os_demo_username

# Create proper role for demo user
openstack --insecure role add --user $os_demo_username --project $os_demo_project_name user

# Show the demo user
openstack --insecure user show $os_demo_username
