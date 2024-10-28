#
# git repo base URIs
#
github = 'https://github.com/'
#local  = 'iaas@git.norcams.org:'

#
# profile::base::common
#
mod 'sudo', :ref => 'v5.0.0',                       :git => github + 'saz/puppet-sudo'
mod 'ssh', :ref => 'v10.2.0',                       :git => github + 'saz/puppet-ssh'
mod 'ntp', :ref => '7.0.0',                         :git => github + 'puppetlabs/puppetlabs-ntp'
mod 'chrony', :ref => 'v1.0.0',                     :git => github + 'voxpupuli/puppet-chrony'
mod 'accounts', :ref => '0fa8ec2e37',               :git => github + 'norcams/puppet-accounts'
mod 'timezone', :ref => 'v6.1.0',                   :git => github + 'saz/puppet-timezone.git'
mod 'debconf', :ref => 'v2.0.0',                    :git => github + 'smoeding/puppet-debconf'
mod 'keyboard', :ref => '0.1.0',                    :git => github + 'norcams/puppet-keyboard'
mod 'hostname', :ref => '0.0.2',                    :git => github + 'peopleware/puppet-hostname'
mod 'resolv_conf', :ref => 'v3.3.0',                :git => github + 'saz/puppet-resolv_conf'
mod 'lvm', :ref => 'v1.4.0',                        :git => github + 'puppetlabs/puppetlabs-lvm'
mod 'mount_core', :ref => '1.0.4',                  :git => github + 'puppetlabs/puppetlabs-mount_core'
mod 'firewall', :ref => 'v3.4.0',                   :git => github + 'puppetlabs/puppetlabs-firewall'
mod 'apt', :ref => '6.2.1',                         :git => github + 'puppetlabs/puppetlabs-apt'
mod 'yumrepo_core', :ref => '1.0.7',                :git => github + 'puppetlabs/puppetlabs-yumrepo_core'
mod 'vcsrepo', :ref => 'v5.5.0',                    :git => github + 'puppetlabs/puppetlabs-vcsrepo'
mod 'kmod', :ref => 'v3.0.0',                       :git => github + 'voxpupuli/puppet-kmod'
mod 'named_interfaces', :ref => 'v1.0.1',           :git => github + 'norcams/puppet-named_interfaces'
mod 'network', :ref => '956881b',                   :git => github + 'norcams/puppet-network'
# mod 'apt', :ref => '2.2.2',                         :git => github + 'puppetlabs/puppetlabs-apt'
mod 'selinux', :ref => 'v3.4.0',                    :git => github + 'voxpupuli/puppet-selinux'
mod 'puppet', :ref => '18.0.0',                     :git => github + 'theforeman/puppet-puppet.git'
mod 'systemd', :ref => 'v3.2.0',                    :git => github + 'voxpupuli/puppet-systemd'
# used to manage yum repos
mod 'openstack_extras', :ref => '16.4.0',           :git => github + 'openstack/puppet-openstack_extras'

#
# FreeBSD spesific
#
# mod 'bsd', :ref => '209a74375d',                    :git => github + 'norcams/puppet-bsd'

#
# profile::base::login
#
mod 'googleauthenticator', :ref => 'norcams-4.0.0-2', :git => github + 'norcams/puppet-googleauthenticator'

#
# profile::network::leaf/torack
#
mod 'quagga', :ref => '42f883092d',                 :git => github + 'norcams/puppet-quagga'
mod 'frrouting', :ref => '70450dd6de',              :git => github + 'norcams/puppet-frrouting'

#
# profile::network::
#
mod 'bird', :ref => 'v4.1.0',                       :git => github + 'voxpupuli/puppet-bird'
mod 'calico', :ref => 'v1.0.14',                    :git => github + 'norcams/puppet-calico'
mod 'dnsmasq', :ref => 'b04a474295',                :git => github + 'saz/puppet-dnsmasq'
mod 'ipcalc', :ref => '2.2.0',                      :git => github + 'inkblot/puppet-ipcalc'
# FIXME: remove tinyproxy when all proxies have el8
mod 'tinyproxy', :ref => 'ef4a8b0bb2',              :git => github + 'earsdown/puppet-tinyproxy'
mod 'cumuluslinux-cumulus_interfaces', :ref => 'norcams', :git => github + 'norcams/cumulus-cl-interfaces-puppet'

#
# profile::application::etcd
#
mod 'etcd', :ref => '1.12.3',                       :git => github + 'puppet-etcd/puppet-etcd'

#
# profile::application::openssl
#
mod 'openssl', :ref => '1.10.0',                    :git => github + 'camptocamp/puppet-openssl'

#
# profile::application::consul
#
#mod 'consul', :ref => 'v3.1.2',                     :git => github + 'solarkennedy/puppet-consul'

#
# profile::application::dpapp
#
mod 'dpapp', :ref => '1.4',                         :git => github + 'norcams/puppet-dpapp'

#
# profile::application::git
#
mod 'gitolite', :ref => '1.1',                      :git => github + 'uib/puppet-gitolite'

#mod 'voxpupuli/alternatives', :ref => 'v2.0.0',     :git => github + 'voxpupuli/puppet-alternatives'
#mod 'voxpupuli/extlib', :ref => 'v6.2.0',           :git => github + 'voxpupuli/puppet-extlib.git'
#mod 'puppetlabs/ruby', :ref => '1.0.0',             :git => github + 'puppetlabs/puppetlabs-ruby'
#mod 'puppetlabs/xinetd', :ref => '3.0.0',           :git => github + 'puppetlabs/puppetlabs-xinetd'
#mod 'systemd', :ref => 'v3.2.0',                    :git => github + 'voxpupuli/puppet-systemd'

#
# bootstrap
#
#mod 'himlar_bootstrap', :ref => '2.0.2',            :git => github + 'norcams/puppet-himlar_bootstrap'
mod 'bootstrap_infra', :ref => 'master',            :git => github + 'norcams/puppet-bootstrap_infra'

#
# profile::logging
#
mod 'rsyslog', :ref => 'v5.2.0',                    :git => github + 'voxpupuli/puppet-rsyslog'
mod 'logstash', :ref => '6.1.5',                    :git => github + 'elastic/puppet-logstash'
mod 'datacat', :ref => '0.6.2',                     :git => github + 'richardc/puppet-datacat'
mod 'elasticsearch', :ref => '6.4.0',               :git => github + 'elastic/puppet-elasticsearch'
mod 'file_concat', :ref => '1.0.1',                 :git => github + 'electrical/puppet-lib-file_concat'
mod 'logrotate', :ref => 'v6.0.0',                  :git => github + 'voxpupuli/puppet-logrotate'

#
# profile::monitoring
#
mod 'sensuclassic', :ref => 'v3.5.0',               :git => github + 'sensu/puppet-module-sensuclassic'
mod 'sensu', :ref => 'v5.8.0',                      :git => github + 'sensu/sensu-puppet'
mod 'uchiwa', :ref => 'v1.0.1',                     :git => github + 'yelp/puppet-uchiwa'
mod 'graphite', :ref => 'v7.2.0',                   :git => github + 'echocat/puppet-graphite' # fixed upstream
mod 'redis', :ref => 'v8.5.0',                      :git => github + 'voxpupuli/puppet-redis'
mod 'grafana', :ref => 'v8.0.0',                    :git => github + 'voxpupuli/puppet-grafana'
mod 'statsd', :ref => '3.1.0',                      :git => github + 'justindowning/puppet-statsd'
mod 'netdata', :ref => '1f8bcef',                   :git => github + 'norcams/denver-netdata'
mod 'collectd', :ref => 'v12.2.0',                  :git => github + 'voxpupuli/puppet-collectd'
mod 'telegraf', :ref => 'v4.2.0',                   :git => github + 'voxpupuli/puppet-telegraf'
mod 'influxdb', :ref => 'norcams',                  :git => github + 'norcams/influxdb'
#mod 'prometheus', :ref => 'v12.2.0',                :git => github + 'voxpupuli/puppet-prometheus'

#
# profile::webserver::apache
#
mod 'puppetlabs/apache', :ref => 'v8.3.0',          :git => github + 'puppetlabs/puppetlabs-apache'

#
# profile::database::postgresql
#
#mod 'postgresql', :ref => 'v9.2.0',                 :git => github + 'puppetlabs/puppetlabs-postgresql'

#
# profile::database::mariadb
#
# mod 'mariadbrepo', ref => '0.2.1',                :git => github + 'Mylezeem/puppet-mariadbrepo'
# mod 'staging', :ref => '1.0.4',                   :git => github + 'nanliu/puppet-staging' why this fork?
mod 'staging', :ref => 'v3.0.0',                    :git => github + 'voxpupuli/puppet-staging'
# FIXME use version of mysql module
#mod 'mysql', :ref => 'norcams/v10.3.0',             :git => github + 'norcams/puppetlabs-mysql'
#mod 'galera_arbitrator', :ref => '1.0.4',           :git => github + 'jadestorm/puppet-galera_arbitrator'


#
# profile::messaging::rabbitmq
#
mod 'erlang', :ref => '23fb75b8b1',                 :git => github + 'garethr/garethr-erlang'
mod 'rabbitmq', :ref => 'v11.1.0',                  :git => github + 'voxpupuli/puppet-rabbitmq'
mod 'archive', :ref => 'v2.2.0',                    :git => github + 'voxpupuli/puppet-archive'


#mod 'openstacklib', :ref => '16.2.0',               :git => github + 'openstack/puppet-openstacklib'
mod 'sysctl', :ref => 'v0.0.11',                    :git => github + 'duritong/puppet-sysctl'
#mod 'memcached', :ref => 'v3.0.2',                  :git => github + 'saz/puppet-memcached'
#mod 'rsync', :ref => '0.4.0',                       :git => github + 'puppetlabs/puppetlabs-rsync'

#
# libvirt
#
mod 'libvirt', :ref => 'norcams',                   :git => github + 'norcams/puppet-libvirt'

#
# ceph
#
mod 'ceph', :ref => '5.0.0',                        :git => github + 'openstack/puppet-ceph'

#
# ha
#
mod 'haproxy', :ref => 'v6.5.0',                    :git => github + 'puppetlabs/puppetlabs-haproxy'
mod 'corosync', :ref => 'v6.0.1',                   :git => github + 'voxpupuli/puppet-corosync'
mod 'zookeeper', :ref => 'v0.8.1',                  :git => github + 'deric/puppet-zookeeper'

# nfs
#
mod 'multipath', :ref => '7c3b65eba5',              :git => github + 'desalvo/puppet-multipath'
mod 'nfs', :ref => '0.4.3',                         :git => github + 'camptocamp/puppet-nfs'

#
# Red Hat Subscription Management (RHSM)
#
mod 'transition', :ref => '0.1.3',                  :git => github + 'puppetlabs/puppetlabs-transition'
mod 'boolean', :ref => 'v2.0.2',                    :git => github + 'voxpupuli/puppet-boolean'
mod 'facter_cacheable', :ref => '1.1.1',            :git => github + 'waveclaw/puppet-facter_cacheable'
mod 'subscription_manager', :ref => '5.5.0',        :git => github + 'waveclaw/puppet-subscription_manager'

#
# Common libs
#
mod 'stdlib', :ref => 'v7.1.0',                     :git => github + 'puppetlabs/puppetlabs-stdlib'
mod 'extlib', :ref => 'v6.2.0',                     :git => github + 'voxpupuli/puppet-extlib.git'
mod 'translate', :ref => 'v2.2.0',                  :git => github + 'puppetlabs/puppetlabs-translate'
mod 'concat', :ref => '4.1.0',                      :git => github + 'puppetlabs/puppetlabs-concat'
mod 'hash_file', :ref => '1.0.3',                   :git => github + 'fiddyspence/puppet-hash_file' # ??
mod 'inifile', :ref => 'v5.2.0',                    :git => github + 'puppetlabs/puppetlabs-inifile'
mod 'augeasproviders_apache', :ref => '3.1.1',      :git => github + 'hercules-team/augeasproviders_apache'
mod 'augeasproviders_core', :ref => '2.1.4',        :git => github + 'hercules-team/augeasproviders_core'
mod 'augeasproviders_base', :ref => '2.0.1',        :git => github + 'hercules-team/augeasproviders_base'
mod 'augeasproviders_grub', :ref => '3.0.0',        :git => github + 'hercules-team/augeasproviders_grub'
mod 'augeasproviders_mounttab', :ref =>'2.0.2',     :git => github + 'hercules-team/augeasproviders_mounttab'
mod 'augeasproviders_nagios', :ref => '2.0.1',      :git => github + 'hercules-team/augeasproviders_nagios'
mod 'augeasproviders_pam', :ref => '2.1.1',         :git => github + 'hercules-team/augeasproviders_pam'
mod 'augeasproviders_postgresql', :ref=>'2.0.4',    :git => github + 'hercules-team/augeasproviders_postgresql'
mod 'augeasproviders_puppet', :ref => '2.1.1',      :git => github + 'hercules-team/augeasproviders_puppet'
mod 'augeasproviders_shellvar', :ref => '2.2.2',    :git => github + 'hercules-team/augeasproviders_shellvar'
mod 'augeasproviders_ssh', :ref => '2.5.2',         :git => github + 'hercules-team/augeasproviders_ssh'
# This conflicts with duritong/sysctl which is used in openstack/* modules
# mod 'augeasproviders_sysctl', :ref => '2.0.1',      :git => github + 'hercules-team/augeasproviders_sysctl'
mod 'augeasproviders_syslog', :ref => '2.1.1',      :git => github + 'hercules-team/augeasproviders_syslog'
