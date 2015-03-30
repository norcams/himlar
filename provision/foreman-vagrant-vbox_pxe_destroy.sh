#!/bin/bash

VMNAME="${1:-"foreman-pxeinstance"}"

VBoxManage controlvm $VMNAME poweroff
VBoxManage unregistervm $VMNAME --delete

