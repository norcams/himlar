#!/bin/bash -vx

vboxifs="$(VBoxManage list hostonlyifs | awk '/^Name/ { print $2 }')"

echo $vboxifs | xargs -n 1 VBoxManage hostonlyif remove
echo $vboxifs | xargs -n 1 VBoxManage dhcpserver remove --ifname
