#
# git repo base URIs
#
github = 'https://github.com/'
local  = 'iaas@git.norcams.org:'

#
# profile::base::common
#
mod 'sudo', :ref => '80cbf884',                  :git => github + 'saz/puppet-sudo'
mod 'ssh', :ref => 'v2.4.0',                     :git => github + 'saz/puppet-ssh'
mod 'ntp', :ref => '3.3.0',                      :git => github + 'puppetlabs/puppetlabs-ntp'
mod 'accounts', :ref => 'e12dd12bb8',            :git => github + 'norcams/puppet-accounts'
mod 'timezone', :ref => 'v3.1.1',                :git => github + 'saz/puppet-timezone.git'
mod 'keyboard', :ref => '0.1.0',                 :git => github + 'norcams/puppet-keyboard'
mod 'hostname', :ref => '0.0.2',                 :git => github + 'peopleware/puppet-hostname'
mod 'resolv_conf', :ref => 'v3.0.3',             :git => github + 'saz/puppet-resolv_conf'
mod 'lvm', :ref => '689d42a16c',                 :git => github + 'puppetlabs/puppetlabs-lvm'
mod 'firewall', :ref => '1.5.0',                 :git => github + 'puppetlabs/puppetlabs-firewall'
mod 'kmod', :ref => '2.1.0',                     :git => github + 'camptocamp/puppet-kmod'
mod 'named_interfaces', :ref => '0.2.0',         :git => github + 'norcams/puppet-named_interfaces'
mod 'network', :ref => 'v3.1.26-11-g3aa6685',    :git => github + 'beddari/puppet-network'
mod 'ipmi', :ref => 'c4309504fd',                :git => github + 'norcams/puppet-ipmi'
mod 'lldp', :ref => '06523de010',                :git => github + 'norcams/puppet-lldp'

#
# profile::base::login
#
mod 'googleauthenticator', :ref => 'norcams-0.1.0', :git => github + 'norcams/puppet-googleauthenticator'

#
# profile::network::leaf
#
mod 'quagga', :ref => 'master',                  :git => github + 'LeslieCarr/puppet-quagga'

#
# profile::network::
#
mod 'bird', :ref => 'master',                    :git => github + 'norcams/puppet-bird'
mod 'calico', :ref => 'master',                  :git => github + 'norcams/puppet-calico'
mod 'dnsmasq', :ref => 'v1.2.0',                 :git => github + 'saz/puppet-dnsmasq'
mod 'ipcalc', :ref => '1.2.2',                   :git => github + 'inkblot/puppet-ipcalc'
mod 'tinyproxy', :ref => 'bc56e3ecc2',           :git => github + 'earsdown/puppet-tinyproxy'

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
mod 'dpapp', :ref => '0.1',                      :git => github + 'norcams/puppet-dpapp'

#
# profile::application::git
#
mod 'gitolite', :ref => '1.0',                   :git => github + 'uib/puppet-gitolite'

# profile::application::foreman
#
mod 'zack/r10k', '2.5.2'                         # forge
mod 'theforeman/foreman', :ref => '1d0a5d397c',  :git => github + 'theforeman/puppet-foreman.git'
mod 'theforeman/concat_native', '1.3.1'          # forge
mod 'theforeman/tftp', '1.6.0'                   # forge
mod 'theforeman/puppet', :ref => '26e1213d0d',   :git => github + 'theforeman/puppet-puppet.git'
mod 'theforeman/dns', '1.4.0'                    # forge
mod 'theforeman/dhcp', :ref => '3a898b5a6c',     :git => github + 'norcams/puppet-dhcp.git'
mod 'theforeman/foreman_proxy', '2.4.2'          # forge
mod 'theforeman/git', '1.4.0'                    # forge
mod 'adrien/alternatives', '0.3.0'               # forge
mod 'voxpupuli/extlib', :ref => '3ed4231eeb',    :git => github + 'voxpupuli/puppet-extlib.git'
mod 'puppetlabs/ruby', '0.4.0'                   # forge
mod 'puppetlabs/xinetd', '1.4.0'                 # forge
mod 'eyaml', :ref => 'v0.3.0',                   :git => github + 'ghoneycutt/puppet-module-eyaml'
mod 'bind', :ref => 'keyfile_resource_record',   :git => github + 'norcams/puppet-bind'

#
# foreman_bootstrap
#
mod 'foreman_bootstrap', :ref => '0.1.6',        :git => github + 'norcams/puppet-foreman_bootstrap'

#
# profile::webserver::apache
#
mod 'puppetlabs/apache', '1.7.1'                 # forge

#
# profile::database::postgresql
#
mod 'postgresqlrepo', :ref => 'master',          :git => github + 'Mylezeem/puppet-postgresqlrepo.git'
mod 'postgresql', :ref => 'pg_hba_rules',        :git => github + 'Mylezeem/puppetlabs-postgresql.git'

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
mod 'rabbitmq', :ref => '5.1.0',                 :git => github + 'puppetlabs/puppetlabs-rabbitmq'

#
# profile::openstack::*
#
mod 'keystone', :ref => '7.0.0-6-g7e8bbf6',      :git => github + 'norcams/puppet-keystone'
mod 'glance', :ref => 'f4495d93a0',              :git => github + 'openstack/puppet-glance'
mod 'nova', :ref => 'a495b4010d',                :git => github + 'openstack/puppet-nova'
mod 'cinder', :ref => '5add15bc80',              :git => github + 'openstack/puppet-cinder'
mod 'horizon', :ref => '7.0.0-2-ga6e7c64',       :git => github + 'norcams/puppet-horizon'
mod 'neutron', :ref => '7.0.0-14-g51c6383',      :git => github + 'norcams/puppet-neutron'

mod 'openstacklib', :ref => '7.0.0',             :git => github + 'openstack/puppet-openstacklib'
mod 'openstack_extras', :ref => '7.0.0',         :git => github + 'openstack/puppet-openstack_extras'
mod 'sysctl', :ref => 'v0.0.8',                  :git => github + 'duritong/puppet-sysctl'
mod 'memcached', :ref => 'v2.8.1',               :git => github + 'saz/puppet-memcached'

#
# libvirt
#
mod 'libvirt', :ref => '0.3.2-norcams1',         :git => github + 'norcams/puppet-libvirt'

#
# ceph
#
mod 'ceph', :ref => '998e023d8f',                :git => github + 'openstack/puppet-ceph'

#
# Common libs
#
mod 'stdlib', :ref => '4.6.0',                   :git => github + 'puppetlabs/puppetlabs-stdlib'
mod 'concat', :ref => '1.1.2',                   :git => github + 'puppetlabs/puppetlabs-concat'
mod 'hash_file', :ref => '1.0.2',                :git => github + 'fiddyspence/puppet-hash_file'
mod 'inifile', :ref => '1.2.0',                  :git => github + 'puppetlabs/puppetlabs-inifile'
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
