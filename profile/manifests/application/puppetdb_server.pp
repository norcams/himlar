#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/puppetdb'
#   mod 'puppetlabs/inifile'
#   mod 'puppetlabs/postgresql'
#   mod 'puppetlabs/firewall'
#   mod 'puppetlabs/stdlib
#
class profile::application::puppetdb_server {

  include ::puppetdb::server
}
