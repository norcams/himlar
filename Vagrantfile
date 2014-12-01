# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision=<<SHELL
  install_puppet_and_tooling()
  {
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    yum install -y puppet facter rubygems rubygem-deep_merge \
      rubygem-puppet-lint git
  }
  export PATH=$PATH:/usr/local/bin
  command -v puppet >/dev/null 2>&1 || install_puppet_and_tooling
  command -v r10k >/dev/null 2>&1   || gem install r10k --no-ri --no-rdoc
SHELL

$puppetrun=<<SHELL
  export PATH=$PATH:/usr/local/bin
  environment=/etc/puppet/environments/production
  source=/vagrant

  mkdir -p $environment $source/modules
  ln -sf $source/hieradata /etc/puppet/
  ln -sf $source/modules $environment/

  cd $source && r10k --verbose 3 puppetfile install

  puppet config set trusted_node_data true
  puppet config set environmentpath ${environment%/*}
  puppet config set hiera_config $source/hiera.yaml
  puppet config set certname base-vagrant-dev.vagrant.local
  puppet config set disable_warnings deprecations
  puppet apply --verbose $source/site.pp
SHELL

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'norcams/centos7'

  config.vm.synced_folder '.', '/vagrant', type: 'rsync',
    rsync__exclude: [ '.git/', '.vagrant/' ]

  config.vm.provision :shell, :inline => $provision
  config.vm.provision :shell, :inline => $puppetrun

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
  end

  config.vm.provider :virtualbox do |provider, override|
    provider.customize ['modifyvm', :id, '--ioapic', 'on']
    provider.customize ['modifyvm', :id, '--cpus', 2]
    provider.customize ['modifyvm', :id, '--memory', 1024]
  end

end

