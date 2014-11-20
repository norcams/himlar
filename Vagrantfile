# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision=<<SHELL

install_puppet()
{
  rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
  yum install -y puppet facter
}

export PATH=$PATH:/usr/local/bin
command -v puppet >/dev/null || install_puppet
command -v gem >/dev/null || sudo yum -y install rubygems
command -v r10k >/dev/null || sudo gem install r10k --no-ri --no-rdoc

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

  config.vm.provision :shell, :inline => $provision

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :machine
  end

end

