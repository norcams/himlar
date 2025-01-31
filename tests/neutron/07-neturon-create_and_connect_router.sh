#!/bin/bash -vx
neutron router-create testrouter
neutron router-gateway-set testrouter floatingnet
neutron router-interface-add testrouter testsubnet
