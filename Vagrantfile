# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision=<<SHELL
  install_puppet_and_tools()
  {
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
    yum install -y puppet facter rubygems rubygem-deep_merge \
      rubygem-puppet-lint git vim inotify-tools
    # puppet settings
    ln -sfT /vagrant/hieradata /etc/puppet/hieradata
    puppet config set hiera_config /vagrant/hiera.yaml
    puppet config set basemodulepath /vagrant/modules:/etc/puppet/modules
    puppet config set disable_warnings deprecations
    puppet config set trusted_node_data true
  }
  install_puppetfile()
  {
    PUPPETFILE=/vagrant/Puppetfile \
    PUPPETFILE_DIR=/etc/puppet/modules \
    r10k --verbose 4 puppetfile install
  }
  export PATH=$PATH:/usr/local/bin
  command -v puppet >/dev/null 2>&1      || install_puppet_and_tools
  command -v r10k >/dev/null 2>&1        || gem install r10k --no-ri --no-rdoc
  test -n "$(ls -A /etc/puppet/modules)" || install_puppetfile
SHELL

$puppetrun=<<SHELL
  # remove modules that are overridden in /vagrant/modules
  modules="$(ls -d /vagrant/modules/*/)"
  for m in $modules; do
    echo "$m is overridden in /vagrant/modules"
    rm -rf /etc/puppet/$(echo ${m#/vagrant/})
  done

  if [ -z "$HIMLAR_CERT_NAME" ]; then
    HIMLAR_CERT_NAME=vagrant-base-dev.vagrant.local
  fi
  puppet config set certname "$HIMLAR_CERT_NAME"
  puppet apply --verbose /vagrant/manifests/site.pp
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

