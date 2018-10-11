#!/bin/bash

# host limit are based on lines in host (two lines per host)
host_limit=10*2

dhcp_dir='/var/lib/neutron/dhcp/'

if (($(ls -1 ${dhcp_dir} | wc -l) < 1)); then
  echo 'Mtime OK: No networks found. Dropped check'
  exit 0
fi

if [ $1 == 'first' ];then
  network=$(ls -1 $dhcp_dir | head -n 1)
elif [ $1 == 'last' ];then
  network=$(ls -1 $dhcp_dir | tail -n 1)
else
  network=$(ls -1 $dhcp_dir | head -n 1)
fi

dir="${dhcp_dir}${network}"
if [ -f ${dir}/host ] && (($(cat ${dir}/host | wc -l) > $host_limit)); then
  /opt/sensu/embedded/bin/check-mtime.rb -f ${dir}/leases -c $2 -w $3
else
  echo 'Mtime OK: Not enough hosts. Check dropped'
  exit 0
fi
