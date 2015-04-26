#!/bin/bash -vx
IMAGE_ID=$(nova image-list | awk '/CirrOS/ { print $2 }' | head -n 1)
NET_ID=$(neutron net-show testnet | grep " id " | awk '{ print $4 }')
nova boot --flavor 1 --image ${IMAGE_ID} --nic net-id=${NET_ID} --security_group test test-1
