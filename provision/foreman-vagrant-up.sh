#!/bin/bash -x
set -o errexit

# Assumes libvirt provider
HIMLAR_INTERN=true HIMLAR_CERTNAME=vagrant-foreman-dev.himlar.local vagrant up base --provider=libvirt

# Run settings script to configure Foreman
vagrant ssh base -c "sudo /opt/himlar/provision/foreman-settings.sh"

# Run puppet to generate a report to Foreman
vagrant ssh base -c "sudo puppet agent -t"
