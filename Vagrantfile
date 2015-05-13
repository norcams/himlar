# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

unless defined? settings
  configuration_file = File.join(File.dirname(__FILE__), 'nodes.yaml')
  settings = YAML.load(File.open(configuration_file, File::RDONLY).read)
  # By default we only load a box with the role 'base' and set it to autostart
  unless ENV['HIMLAR_MULTINODE'] == 'true'
    settings['nodes'] = Array.new(1, Hash.new)
    settings['nodes'][0]['role'] = 'base'
    settings['nodes'][0]['autostart'] = true
    settings['nodes'][0]['primary'] = true
  end
  # Map defaults settings to each node
  settings['nodes'].each do |n|
    n.merge!(settings['defaults']) { |key, nval, tval | nval }
  end
end

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  settings['nodes'].each_with_index do |n, i|
    config.vm.define n['role'], autostart: n['autostart'], primary: n['primary'] do |box|
      box.vm.hostname = "%s-%s-%s.%s" % [ n['location'],n['role'],n['hostid'],n['domain'] ]
      box.vm.box = n['box']
      box.vm.box_url = n['box_url']
      n['networks'].each do |net|
        ip = settings['networks'][net]['net'] + ".#{i+11}"
        auto_config = settings['networks'][net]['auto_config']
        box.vm.network :private_network, ip: ip, libvirt__dhcp_enabled: auto_config, auto_config: auto_config
      end

      # Pass environment variables to the provisioning scripts
      ENV['HIMLAR_CERTNAME'] = "%s-%s-%s.%s" % [ n['location'],n['role'],n['hostid'],n['domain'] ]
      env_data = ENV.select { |k, _| /^HIMLAR_|^FACTER_/i.match(k) }
      args = env_data.map { |k, v| "#{k}=#{v}" }
      box.vm.provision :shell, :path => 'provision/puppetbootstrap.sh', args: args
      box.vm.provision :shell, :path => 'provision/puppetmodules.sh', args: args
      box.vm.provision :shell, :path => 'provision/puppetrun.sh', args: args

      box.vm.provider :virtualbox do |vbox|
        vbox.customize ['modifyvm', :id, '--ioapic', 'on']
        vbox.customize ['modifyvm', :id, '--cpus',   n['cpus']]
        vbox.customize ['modifyvm', :id, '--memory', n['memory']]
        vbox.customize ['modifyvm', :id, '--name',   n['role']]
      end

      box.vm.provider :libvirt do |libvirt|
        libvirt.driver = 'kvm'
        libvirt.cpus   = n['cpus']
        libvirt.memory = n['memory']
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
