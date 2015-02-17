# Create libvirt VM - Assumes two interfaces with no IP addresses
HIMLAR_BRIDGE=bond0.909 HIMLAR_BRIDGE2=bond0.908 vagrant up base --provider=libvirt --no-provision

