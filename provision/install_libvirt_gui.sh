#!/bin/bash
# CentOS 6, 7, Fedora 20/21
sudo yum -y install virt-manager virt-viewer

# Allow users to connect to VMs locally
echo '
polkit.addRule(function(action, subject) {
  if ((action.id == "org.libvirt.unix.manage"
    || action.id == "org.libvirt.unix.monitor")
    && subject.isInGroup("wheel")) {
    return polkit.Result.YES;
  }
});
' | sudo tee /etc/polkit-1/rules.d/10.libvirt.rules
