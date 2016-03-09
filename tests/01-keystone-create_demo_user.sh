#!/bin/bash -x
set -o errexit

source ~/openstack.config
source ~/keystonerc_admin

# Create a demo tenant (project)
openstack project create --or-show $os_demo_project_name

# Create a demo user
openstack user create --or-show --password "$os_demo_password" $os_demo_username

# Associate the demo user with the demo tenant
openstack user set --project $os_demo_project_name $os_demo_username

# Show the demo user
openstack user show $os_demo_username
