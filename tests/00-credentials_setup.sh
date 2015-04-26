#!/bin/bash

echo '
os_url="http://10.0.3.14:35357/v2.0"
os_token="admintoken"
os_username="demo"
os_password="himlar0pen"
osadmin()
{
  openstack --os-token $os_token --os-url $os_url "$@"
}

osuser()
{
  openstack --os-username $os_username --os-password $os_password --os-url $os_url "$@"
}
' > ~/openstack.config

