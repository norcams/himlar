#!/bin/bash

# input peer link ipv4
peer=$1
json_file="/tmp/${peer}.json"

#vrf info
echo $#
if [ $# -eq 2 ]; then
    vrf="vrf ${2}"
else
    vrf=""
fi

vtysh -c "show ip bgp ${vrf} neighbors ${peer} json" > $json_file

if [ $(wc -l < ${json_file}) -gt 10 ]; then
    # First check bgp state
    if [ $(jq 'to_entries[0].value.bgpState' ${json_file}) == \"Established\" ]; then
        # Then check bfd status
        if [ $(jq 'to_entries[0].value.peerBfdInfo.status' ${json_file}) == \"Up\" ]; then
            echo "BGP and BfD is fine!"
            rm -f ${json_file}
            exit 0
        else
            echo "Check BfD status"
            rm -f ${json_file}
            exit 2
        fi
    else
        echo "Check bgp state $(jq 'to_entries[0].value.bgpState' ${json_file})"
        rm -f ${json_file}
        exit 2
    fi
else
    echo "Problem: neighbor data to small"
    cat ${json_file}
    rm -f ${json_file}
    exit 1
fi
