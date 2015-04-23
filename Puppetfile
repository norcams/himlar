#
# git repo base URIs
#
github = 'https://github.com/'
local  = 'iaas@git.norcams.org:'

#
# profile
#
mod 'profile', :ref => 'norcams-0.4.0',          :git => github + 'norcams/puppeels'

#
# profile::base::common
#
mod 'epel', :ref => '1.0.0',                     :git => github + 'stahnma/puppet-module-epel'
mod 'sudo', :ref => 'v3.0.9',                    :git => github + 'saz/puppet-sudo'
mod 'ssh', :ref => 'v2.4.0',                     :git => github + 'saz/puppet-ssh'
mod 'ntp', :ref => '3.3.0',                      :git => github + 'puppetlabs/puppetlabs-ntp'
mod 'account', :ref => 'multiple_accounts',      :git => github + 'Mylezeem/puppet-account.git'
mod 'timezone', :ref => 'v3.1.1',                :git => github + 'saz/puppet-timezone.git'
mod 'netcf', :ref => '4c3142e4f7',               :git => github + 'raphink/puppet-netcf.git'
mod 'hostname', :ref => '0.0.2',                 :git => github + 'peopleware/puppet-hostname'
mod 'resolv_conf', :ref => 'v3.0.3',             :git => github + 'saz/puppet-resolv_conf'
mod 'lvm', :ref => 'ordering',                   :git => github + 'TorLdre/puppetlabs-lvm'
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
mod 'foreman_bootstrap', :ref => '0.1.4',        :git => github + 'norcams/puppet-foreman_bootstrap'

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
mod 'keystone', :ref => '9b54046486',            :git => github + 'enovance/puppet-keystone'
mod 'glance', :ref => '3cd398e9',                :git => github + 'stackforge/puppet-glance'
mod 'nova', :ref => '23ba8212cf',                :git => github + 'stackforge/puppet-nova'
mod 'cinder', :ref => '9075f74163',              :git => github + 'stackforge/puppet-cinder'

mod 'openstacklib', :ref => '5.0.0',             :git => github + 'stackforge/puppet-openstacklib'
mod 'sysctl', :ref => 'v0.0.8',                  :git => github + 'duritong/puppet-sysctl'

#
# profile::openstack::
#

#
# libvirt
#
mod 'libvirt', :ref => '0.3.2-norcams1',         :git => github + 'norcams/puppet-libvirt'

#
# ceph
#
mod 'ceph', :ref => 'b6ab15b47c',                :git => github + 'stackforge/puppet-ceph'

#
# Common libs
#
mod 'sitelib', :ref => '0.1.0',                  :git => github + 'norcams/himlar-sitelib'
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

