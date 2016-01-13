#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'sensu/sensu'
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#   mod 'puppetlabs/apache'
#   mod 'maestrodev/wget'
#   mod 'puppetlabs/gcc'
#   mod 'thomasvandoren/redis'
#   mod 'puppetlabs/apt'
#   mod 'nanliu/staging'
#   mod 'puppetlabs/rabbitmq'
#   mod 'richardc/datacat'
#   mod 'richardc/datacat'
#   mod 'pauloconnor/uchiwa'
#
class profile::monitoring::sensu::server (
  $handlers                  = {},
  $rabbitmq_user             = 'sensu',
  $rabbitmq_password         = 'rabbitpassword',
  $rabbitmq_vhost            = '/sensu',
  $uchiwa_ip                 = $::ipaddress,
  $proxy_dashboard           = true,
  $vhost_configuration       = {},
  $manage_rabbitmq           = true,
  $manage_redis              = true,
) {

  Class['sensu'] -> Class['uchiwa']

  include ::profile::monitoring::sensu::agent

  if $manage_redis {
    include ::profile::database::redis
    Service['redis'] -> Service['sensu-api'] -> Service['sensu-server']
  }

  if $manage_rabbitmq {
    include ::profile::messaging::rabbitmq
    Service['rabbitmq-server'] -> Class['sensu::package']
  }

  if $proxy_dashboard {
    include ::profile::webserver::apache
    create_resources('apache::vhost', $vhost_configuration)
  }

  create_resources('sensu::handler', $handlers)

  include ::uchiwa

}

