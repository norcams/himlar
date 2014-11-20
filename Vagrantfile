# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision=<<SHELL
command -v r10k 2>/dev/null || sudo gem install r10k --no-ri --no-rdoc
SHELL

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "norcams/centos7"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--memory", 1024]
  end

end
