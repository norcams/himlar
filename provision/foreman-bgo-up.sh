# Assumes libvirt provider
HIMLAR_BRIDGE=bond0.909 HIMLAR_BRIDGE2=bond0.908 HIMLAR_CERTNAME=bgo-foreman-bootstrap.mgmt.iaas.intern vagrant up base --provider=libvirt
vagrant ssh base -c "sudo /opt/himlar/provision/foreman-bgo-setup.sh changeme"

# Run puppet to generate a report to Foreman
vagrant ssh base -c "sudo puppet agent -t"
