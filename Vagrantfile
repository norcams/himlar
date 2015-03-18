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

  # Pass environment variables to the provisioning scripts
  env_data = ENV.select { |k, _| /^HIMLAR_|^FACTER_/i.match(k) }
  args = env_data.map { |k, v| "#{k}=#{v}" }
  if args.any?
    puts "Args: #{args}"
  end

  config.vm.provision :shell, :path => 'provision/puppetbootstrap.sh', args: args
  config.vm.provision :shell, :path => 'provision/puppetmodules.sh', args: args
  config.vm.provision :shell, :path => 'provision/puppetrun.sh', args: args

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ['modifyvm', :id, '--ioapic', 'on']
    vbox.customize ['modifyvm', :id, '--cpus', 2]
    vbox.customize ['modifyvm', :id, '--memory', 2048]
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = 'kvm'
    libvirt.cpus = 2
    libvirt.memory = 2048
  end

  if ENV['HIMLAR_BRIDGE']
    config.vm.network :public_network, dev: ENV['HIMLAR_BRIDGE'], mode: 'bridge', auto_config: false
  end
  if ENV['HIMLAR_BRIDGE2']
    config.vm.network :public_network, dev: ENV['HIMLAR_BRIDGE2'], mode: 'bridge', auto_config: false
  end
  if ENV['HIMLAR_INTERN'] || ENV['HIMLAR_PRIVATE']
    config.vm.network :private_network, ip: '10.0.3.15', libvirt__dhcp_enabled: false, auto_config: false
  end

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end
end

