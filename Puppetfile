#
# git repo base URIs
#
github = 'https://github.com/'
local  = 'iaas@git.norcams.org:'

#
# profile
#
mod 'profile', :ref => 'norcams-0.5.11',         :git => github + 'norcams/puppeels'

#
# profile::base::common
#
mod 'sudo', :ref => '80cbf884',                  :git => github + 'saz/puppet-sudo'
mod 'ssh', :ref => 'v2.4.0',                     :git => github + 'saz/puppet-ssh'
mod 'ntp', :ref => '3.3.0',                      :git => github + 'puppetlabs/puppetlabs-ntp'
mod 'accounts', :ref => 'e12dd12bb8',            :git => github + 'norcams/puppet-accounts'
mod 'timezone', :ref => 'v3.1.1',                :git => github + 'saz/puppet-timezone.git'
mod 'keyboard', :ref => '0.1.0',                 :git => github + 'norcams/puppet-keyboard'
mod 'netcf', :ref => '4c3142e4f7',               :git => github + 'raphink/puppet-netcf.git'
mod 'hostname', :ref => '0.0.2',                 :git => github + 'peopleware/puppet-hostname'
mod 'resolv_conf', :ref => 'v3.0.3',             :git => github + 'saz/puppet-resolv_conf'
mod 'lvm', :ref => '6624b24a9c',                 :git => github + 'puppetlabs/puppetlabs-lvm'
mod 'firewall', :ref => '1.5.0',                 :git => github + 'puppetlabs/puppetlabs-firewall'

#
# profile::base::login
#
mod 'googleauthenticator', :ref => 'norcams-0.1.0', :git => github + 'norcams/puppet-googleauthenticator'

#
# profile::network::leaf
#
mod 'quagga', :ref => 'master',                  :git => github + 'LeslieCarr/puppet-quagga'

#
# profile::network::services
#
mod 'dnsmasq', :ref => 'norcams-0.1.0',          :git => github + 'norcams/puppet-dnsmasq'
mod 'ipcalc', :ref => '1.2.2',                   :git => github + 'inkblot/puppet-ipcalc'

#
# profile::application::etcd
#
mod 'etcd', :ref => '0efd30bbaa',                :git => github + 'norcams/puppet-etcd'

#
# profile::application::foreman
#
mod 'zack/r10k', '2.5.2'                         # forge
mod 'theforeman/foreman', :ref => '2f9e173b',    :git => github + 'theforeman/puppet-foreman.git'
mod 'theforeman/concat_native', '1.3.1'          # forge
mod 'theforeman/tftp', '1.4.3'                   # forge
mod 'theforeman/puppet', :ref => '4cc662969',    :git => github + 'theforeman/puppet-puppet.git'
mod 'theforeman/dns', '1.4.0'                    # forge
mod 'theforeman/dhcp', :ref => '2dd89ddb9c',     :git => github + 'norcams/puppet-dhcp.git'
mod 'theforeman/foreman_proxy', '2.1.0'          # forge
mod 'theforeman/git', '1.4.0'                    # forge
mod 'puppetlabs/ruby', '0.4.0'                   # forge
mod 'puppetlabs/xinetd', '1.4.0'                 # forge
mod 'eyaml', :ref => 'v0.3.0',                   :git => github + 'ghoneycutt/puppet-module-eyaml'
mod 'bind', :ref => 'keyfile_resource_record',   :git => github + 'norcams/puppet-bind'

#
# foreman_bootstrap
#
mod 'foreman_bootstrap', :ref => '0.1.5',        :git => github + 'norcams/puppet-foreman_bootstrap'

#
# profile::webserver::apache
#
mod 'puppetlabs/apache', '1.2.0'                 # forge

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
mod 'keystone', :ref => '4b2e330152',            :git => github + 'enovance/puppet-keystone'
mod 'glance', :ref => 'dbcfaf9b2e',              :git => github + 'norcams/puppet-glance'
mod 'nova', :ref => '3f039d8207',                :git => github + 'stackforge/puppet-nova'
mod 'cinder', :ref => '9a409d9cc7',              :git => github + 'stackforge/puppet-cinder'
mod 'horizon', :ref => 'f04c638817',             :git => github + 'stackforge/puppet-horizon'
mod 'neutron', :ref => 'd5628a9ca1',             :git => github + 'stackforge/puppet-neutron'

mod 'openstacklib', :ref => '5.0.0',             :git => github + 'stackforge/puppet-openstacklib'
mod 'openstack_extras', :ref => 'd4af0036a4',    :git => github + 'stackforge/puppet-openstack_extras'
mod 'vswitch', :ref => '0.3.0',                  :git => github + 'stackforge/puppet-vswitch'
mod 'sysctl', :ref => 'v0.0.8',                  :git => github + 'duritong/puppet-sysctl'
mod 'memcached', :ref => 'd009260de3',           :git => github + 'saz/puppet-memcached'

#
# libvirt
#
mod 'libvirt', :ref => '0.3.2-norcams1',         :git => github + 'norcams/puppet-libvirt'

#
# ceph
#
mod 'ceph', :ref => 'cc4e23c535',                :git => github + 'norcams/puppet-ceph'

#
# profile::application::consul
#
mod 'consul', :ref => '7c428f4b2b',              :git => github + 'solarkennedy/puppet-consul'

#
# Common libs
#
mod 'stdlib', :ref => '4.6.0',                   :git => github + 'puppetlabs/puppetlabs-stdlib'
mod 'concat', :ref => '1.1.2',                   :git => github + 'puppetlabs/puppetlabs-concat'
mod 'inifile', :ref => '1.2.0',                  :git => github + 'puppetlabs/puppetlabs-inifile'
mod 'augeasproviders', :ref => 'v2.1.3',         :git => github + 'hercules-team/augeasproviders'
mod 'augeasproviders_apache', :ref => '2.0.0',   :git => github + 'hercules-team/augeasproviders_apache'
mod 'augeasproviders_core', :ref => '2.1.1',     :git => github + 'hercules-team/augeasproviders_core'
mod 'augeasproviders_base', :ref => '2.0.1',     :git => github + 'hercules-team/augeasproviders_base'
mod 'augeasproviders_grub', :ref => '2.0.1',     :git => github + 'hercules-team/augeasproviders_grub'
mod 'augeasproviders_mounttab', :ref =>'2.0.0',  :git => github + 'hercules-team/augeasproviders_mounttab'
mod 'augeasproviders_nagios', :ref => '2.0.1',   :git => github + 'hercules-team/augeasproviders_nagios'
mod 'augeasproviders_pam', :ref => '2.0.3',      :git => github + 'hercules-team/augeasproviders_pam'
mod 'augeasproviders_postgresql',:ref=>'2.0.3',  :git => github + 'hercules-team/augeasproviders_postgresql'
mod 'augeasproviders_puppet', :ref => '2.0.2',   :git => github + 'hercules-team/augeasproviders_puppet'
mod 'augeasproviders_shellvar', :ref => '2.1.1', :git => github + 'hercules-team/augeasproviders_shellvar'
mod 'augeasproviders_ssh', :ref => '2.2.2',      :git => github + 'hercules-team/augeasproviders_ssh'
mod 'augeasproviders_sysctl', :ref => '2.0.1',   :git => github + 'hercules-team/augeasproviders_sysctl'
mod 'augeasproviders_syslog', :ref => '2.1.1',   :git => github + 'hercules-team/augeasproviders_syslog'

