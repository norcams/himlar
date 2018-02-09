#!/bin/bash -x
#
# This script will patch a machine using patches
# inside a subdirectory named after the role
# After patching it will attempt to run any
# script inside the "script" directory named
# after the role (if any).
#
# ./patch.sh <role/machine>
#
# Example: ./patch.sh compute
#

component=$1

# file to flag that patching has been done
# This is mainly a signal to puppet
flagfile=/var/tmp/system-patched

if [ -z $component ]; then
    echo "Usage: $0 <role>"
    exit 1
fi

# Ensure any required tools are installed
if [ ! $(which patch) ];then
        yum install -y -q patch
fi

# Get a list of all available relevant patches
# and apply them in no documented order
patches=$(find ${component}/ -type f 2>/dev/null)
for patch in $patches; do
    (cd / && patch -p1) < $patch
done

# signal that patching is done and run scripts
# only if patches available
if [ "${patches:+x}" = "x" ]; then
    touch $flagfile

    # Run relevant role specific script if any
    if [ -f script/${component}.sh ]; then
        script/${component}.sh
    fi
fi

