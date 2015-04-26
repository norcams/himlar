#!/bin/bash -x
set -o errexit
neutron security-group-create test_sec_group
neutron security-group-rule-create --direction ingress --protocol tcp --port_range_min 22 --port_range_max 22 test_sec_group
neutron security-group-rule-create --protocol icmp --direction ingress test_sec_group
