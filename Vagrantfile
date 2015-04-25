# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

unless defined? settings
  configuration_file = File.join(File.dirname(__FILE__), 'nodes.yaml')
  settings = YAML.load(File.open(configuration_file, File::RDONLY).read)
  settings['nodes'].each do |node|
    node.merge!(settings['defaults']) { |key, nval, tval | nval }
  end
end

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define 'base', autostart: true, primary: true do |set|
    set.vm.box = settings['defaults']['box']
  end

  if ENV['HIMLAR_MULTINODE']
    settings['nodes'].each_with_index do |node, i|
      config.vm.define node['name'] do |box|
        box.vm.hostname = node['name'] + "." + node['domain']
        box.vm.box = node['box']
        box.vm.box_url = node['box_url']
        node['networks'].each do |n|
          ip = settings['networks'][n]['net'] + ".#{i+11}"
          auto_config = settings['networks'][n]['auto_config']
          box.vm.network :private_network, ip: ip, libvirt__dhcp_enabled: auto_config, auto_config: auto_config
        end

        # Pass environment variables to the provisioning scripts
        ENV['HIMLAR_CERTNAME'] = node['name'] + "." + node['domain']
        env_data = ENV.select { |k, _| /^HIMLAR_|^FACTER_/i.match(k) }
        args = env_data.map { |k, v| "#{k}=#{v}" }
        box.vm.provision :shell, :path => 'provision/puppetbootstrap.sh', args: args
        box.vm.provision :shell, :path => 'provision/puppetmodules.sh', args: args
        box.vm.provision :shell, :path => 'provision/puppetrun.sh', args: args

        box.vm.provider :virtualbox do |vbox|
          vbox.customize ['modifyvm', :id, '--ioapic', 'on']
          vbox.customize ['modifyvm', :id, '--cpus',   node['cpus']]
          vbox.customize ['modifyvm', :id, '--memory', node['memory']]
          vbox.customize ['modifyvm', :id, '--name',   node['name']]
        end

        box.vm.provider :libvirt do |libvirt|
          libvirt.driver = 'kvm'
          libvirt.cpus   = node['cpus']
          libvirt.memory = node['memory']
        end
      end
    end
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/opt/himlar', type: 'rsync',
    rsync__exclude: [ '.git/', '.vagrant/' ]

  if ENV['HIMLAR_BRIDGE']
    config.vm.network :public_network, dev: ENV['HIMLAR_BRIDGE'], mode: 'bridge', auto_config: false
  end

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end
end

