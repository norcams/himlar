# Assumes libvirt provider

HIMLAR_INTERN=true HIMLAR_CERTNAME=vagrant-foreman-dev.vagrant.local vagrant up base --provider=libvirt
vagrant ssh base -c "sudo /opt/himlar/provision/foreman-vagrant-setup.sh changeme"

# Run puppet to generate a report to Foreman
vagrant ssh base -c "sudo puppet agent -t"
