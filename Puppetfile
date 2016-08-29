#
# git repo base URIs
#
github = 'https://github.com/'
local  = 'iaas@git.norcams.org:'

#
# profile::base::common
#
mod 'sudo', :ref => '80cbf884',                  :git => github + 'saz/puppet-sudo'
mod 'ssh', :ref => 'v2.8.1',                     :git => github + 'saz/puppet-ssh'
mod 'ntp', :ref => '3.3.0',                      :git => github + 'puppetlabs/puppetlabs-ntp'
mod 'accounts', :ref => '06955a9455',            :git => github + 'norcams/puppet-accounts'
mod 'timezone', :ref => 'v3.1.1',                :git => github + 'saz/puppet-timezone.git'
mod 'keyboard', :ref => '0.1.0',                 :git => github + 'norcams/puppet-keyboard'
mod 'hostname', :ref => '0.0.2',                 :git => github + 'peopleware/puppet-hostname'
mod 'resolv_conf', :ref => 'v3.0.3',             :git => github + 'saz/puppet-resolv_conf'
mod 'lvm', :ref => '689d42a16c',                 :git => github + 'puppetlabs/puppetlabs-lvm'
mod 'firewall', :ref => '1.5.0',                 :git => github + 'puppetlabs/puppetlabs-firewall'
mod 'kmod', :ref => '2.1.0',                     :git => github + 'camptocamp/puppet-kmod'
mod 'named_interfaces', :ref => '0.2.0',         :git => github + 'norcams/puppet-named_interfaces'
mod 'network', :ref => '0529e7b415',             :git => github + 'norcams/puppet-network'
mod 'ipmi', :ref => 'c4309504fd',                :git => github + 'norcams/puppet-ipmi'
mod 'lldp', :ref => '06523de010',                :git => github + 'norcams/puppet-lldp'
mod 'apt', :ref => '2.2.2',                      :git => github + 'puppetlabs/puppetlabs-apt'

#
# profile::base::login
#
mod 'googleauthenticator', :ref => 'norcams-0.1.1', :git => github + 'norcams/puppet-googleauthenticator'

#
# profile::network::leaf
#
mod 'quagga', :ref => '0e3a7a16bb',              :git => github + 'norcams/puppet-quagga'

#
# profile::network::
#
mod 'bird', :ref => 'master',                    :git => github + 'norcams/puppet-bird'
mod 'calico', :ref => 'calico-dhcp',             :git => github + 'norcams/puppet-calico'
mod 'dnsmasq', :ref => 'v1.2.0',                 :git => github + 'saz/puppet-dnsmasq'
mod 'ipcalc', :ref => '1.2.2',                   :git => github + 'inkblot/puppet-ipcalc'
mod 'tinyproxy', :ref => 'bc56e3ecc2',           :git => github + 'earsdown/puppet-tinyproxy'
mod 'interfaces', :ref => '1.2.2',               :git => github + 'CumulusNetworks/cumulus-cl-interfaces-puppet'
mod 'cumulus_license', :ref => '1.1.0',          :git => github + 'CumulusNetworks/cumulus-cl-license-puppet'
mod 'ipcalc', :ref => '1.2.2',                   :git => github + 'inkblot/puppet-ipcalc'

#
# profile::application::etcd
#
mod 'etcd', :ref => 'c26961fe94',                :git => github + 'norcams/puppet-etcd'

#
# profile::application::sslcert
#
mod 'openssl', :ref => '1.5.0',                  :git => github + 'camptocamp/puppet-openssl'

#
# profile::application::consul
#
mod 'consul', :ref => '7c428f4b2b',              :git => github + 'solarkennedy/puppet-consul'

#
# profile::application::dpapp
#
mod 'dpapp', :ref => '1.1',                      :git => github + 'norcams/puppet-dpapp'

#
# profile::application::git
#
mod 'gitolite', :ref => '1.0',                   :git => github + 'uib/puppet-gitolite'

# profile::application::foreman
#
mod 'zack/r10k', '2.5.2'                         # forge
mod 'theforeman/foreman', :ref => '5.2.2',       :git => github + 'theforeman/puppet-foreman.git'
mod 'theforeman/concat_native', '1.3.1'          # forge
mod 'theforeman/tftp', '1.8.1'                   # forge
mod 'theforeman/puppet', :ref => '5.0.0',        :git => github + 'theforeman/puppet-puppet.git'
mod 'theforeman/dns', '3.3.1'                    # forge
mod 'theforeman/dhcp', :ref => '2.3.2-norcams',  :git => github + 'norcams/puppet-dhcp.git'
mod 'theforeman/foreman_proxy', '3.0.1'          # forge
mod 'theforeman/git', '1.4.0'                    # forge
mod 'adrien/alternatives', '0.3.0'               # forge
mod 'voxpupuli/extlib', :ref => 'v0.11.3',      :git => github + 'voxpupuli/puppet-extlib.git'
mod 'puppetlabs/ruby', '0.4.0'                   # forge
mod 'puppetlabs/xinetd', '1.4.0'                 # forge
mod 'eyaml', :ref => 'v0.3.0',                   :git => github + 'ghoneycutt/puppet-module-eyaml'
mod 'bind', :ref => 'keyfile_resource_record',   :git => github + 'norcams/puppet-bind'

#
# foreman_bootstrap
#
mod 'foreman_bootstrap', :ref => '0.1.6',        :git => github + 'norcams/puppet-foreman_bootstrap'
mod 'himlar_bootstrap', :ref => 'master',        :git => github + 'norcams/puppet-himlar_bootstrap'

#
# profile::logging
#
mod 'rsyslog', :ref => '115e358',                 :git => github + 'saz/puppet-rsyslog'
mod 'logstash', :ref => '0.5.1',                  :git => github + 'elastic/puppet-logstash'
mod 'datacat', :ref => '9d2cd07b8777',            :git => github + 'richardc/puppet-datacat'
mod 'elasticsearch', :ref => '0.10.3',            :git => github + 'elastic/puppet-elasticsearch'
mod 'file_concat', :ref => '813132b5d77',         :git => github + 'electrical/puppet-lib-file_concat'

#
# profile::webserver::apache
#
mod 'puppetlabs/apache', '1.10.0'                 # forge

#
# profile::database::postgresql
#
mod 'postgresql', :ref => '4.7.1',                :git => github + 'puppetlabs/puppetlabs-postgresql.git'

#
# profile::database::mariadb
#
#mod 'mariadbrepo', ref => '0.2.1',               :git => github + 'Mylezeem/puppet-mariadbrepo'
mod 'staging', :ref => '1.0.4',                  :git => github + 'nanliu/puppet-staging'
mod 'mysql', :ref => '3.3.0',                    :git => github + 'puppetlabs/puppetlabs-mysql'

#
# profile::messaging::rabbitmq
#
mod 'garethr/erlang'
mod 'rabbitmq', :ref => '8527f20',                 :git => github + 'puppetlabs/puppetlabs-rabbitmq'

#
# profile::openstack::*
#
mod 'keystone', :ref => '71f7964c6a',            :git => github + 'TorLdre/puppet-keystone'
mod 'cinder', :ref => '5add15bc80',              :git => github + 'openstack/puppet-cinder'
mod 'glance', :ref => '8.2.0',                   :git => github + 'openstack/puppet-glance'
mod 'nova', :ref => 'a495b4010d',                :git => github + 'openstack/puppet-nova'
mod 'neutron', :ref => '7.0.0-14-g51c6383',      :git => github + 'norcams/puppet-neutron'
mod 'horizon', :ref => '7.0.0-2-ga6e7c64',       :git => github + 'norcams/puppet-horizon'

mod 'openstacklib', :ref => '8.2.0',             :git => github + 'openstack/puppet-openstacklib'
mod 'openstack_extras', :ref => '8.2.0',         :git => github + 'openstack/puppet-openstack_extras'
mod 'sysctl', :ref => 'v0.0.8',                  :git => github + 'duritong/puppet-sysctl'
mod 'memcached', :ref => 'v2.8.1',               :git => github + 'saz/puppet-memcached'

#
# libvirt
#
mod 'libvirt', :ref => '0.3.2-norcams2',         :git => github + 'norcams/puppet-libvirt'

#
# ceph
#
mod 'ceph', :ref => '998e023d8f',                :git => github + 'openstack/puppet-ceph'

#
# Common libs
#
mod 'stdlib', :ref => '4.12.0',                  :git => github + 'puppetlabs/puppetlabs-stdlib'
mod 'concat', :ref => '1.1.2',                   :git => github + 'puppetlabs/puppetlabs-concat'
mod 'hash_file', :ref => '1.0.2',                :git => github + 'fiddyspence/puppet-hash_file'
mod 'inifile', :ref => '1.5.0',                  :git => github + 'puppetlabs/puppetlabs-inifile'
mod 'augeasproviders', :ref => 'v2.1.3',         :git => github + 'hercules-team/augeasproviders'
mod 'augeasproviders_apache', :ref => '2.0.0',   :git => github + 'hercules-team/augeasproviders_apache'
mod 'augeasproviders_core', :ref => '2.1.1',     :git => github + 'hercules-team/augeasproviders_core'
mod 'augeasproviders_base', :ref => '2.0.1',     :git => github + 'hercules-team/augeasproviders_base'
mod 'augeasproviders_grub', :ref => '86ad46f5',  :git => github + 'hercules-team/augeasproviders_grub'
mod 'augeasproviders_mounttab', :ref =>'2.0.0',  :git => github + 'hercules-team/augeasproviders_mounttab'
mod 'augeasproviders_nagios', :ref => '2.0.1',   :git => github + 'hercules-team/augeasproviders_nagios'
mod 'augeasproviders_pam', :ref => '2.0.3',      :git => github + 'hercules-team/augeasproviders_pam'
mod 'augeasproviders_postgresql',:ref=>'2.0.3',  :git => github + 'hercules-team/augeasproviders_postgresql'
mod 'augeasproviders_puppet', :ref => '2.0.2',   :git => github + 'hercules-team/augeasproviders_puppet'
mod 'augeasproviders_shellvar', :ref => '2.1.1', :git => github + 'hercules-team/augeasproviders_shellvar'
mod 'augeasproviders_ssh', :ref => '2.2.2',      :git => github + 'hercules-team/augeasproviders_ssh'
# This conflicts with duritong/sysctl which is used in openstack/* modules
#mod 'augeasproviders_sysctl', :ref => '2.0.1',   :git => github + 'hercules-team/augeasproviders_sysctl'
mod 'augeasproviders_syslog', :ref => '2.1.1',   :git => github + 'hercules-team/augeasproviders_syslog'
