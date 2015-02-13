# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define 'base', autostart: true, primary: true do |set|
    set.vm.box = 'norcams/base'
  end
  config.vm.define 'netdev', autostart: false, primary: false do |set|
    set.vm.box = 'norcams/netdev'
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/opt/himlar', type: 'rsync',
    rsync__exclude: [ '.git/', '.vagrant/' ]

  config.vm.provision :shell, :path => 'provision/bootstrap.sh'
  config.vm.provision :shell, :path => 'provision/puppetmodules.sh', args: ENV['HIMLAR_PUPPETFILE']
  config.vm.provision :shell, :path => 'provision/puppetrun.sh', args: ENV['HIMLAR_CERTNAME']

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ['modifyvm', :id, '--ioapic', 'on']
    vbox.customize ['modifyvm', :id, '--cpus', 2]
    vbox.customize ['modifyvm', :id, '--memory', 1024]
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = 'kvm'
    libvirt.cpus = 2
    libvirt.memory = 1024
  end

  if ENV['HIMLAR_BRIDGE1']
    config.vm.network :public_network, dev: ENV['HIMLAR_BRIDGE1'], mode: 'bridge', auto_config: false
  end
  if ENV['HIMLAR_BRIDGE2']
    config.vm.network :public_network, dev: ENV['HIMLAR_BRIDGE2'], mode: 'bridge', auto_config: false
  end
  if ENV['HIMLAR_INTERN']
    config.vm.network :private_network, ip: '10.0.1.2', auto_config: false
  end

end

