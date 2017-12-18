#
class profile::monitoring::sensu::server (
  $vhost_configuration       = {},
  $manage_dashboard          = false,
  $manage_rabbitmq           = false,
  $manage_redis              = false,
  $manage_graphite           = false,
  $manage_firewall           = false,
  $firewall_extras           = {}
) {

  if $manage_dashboard {
    Class['sensu'] -> Class['uchiwa']
    include ::uchiwa
    #include ::profile::webserver::apache
    #create_resources('apache::vhost', $vhost_configuration)
  }

  include ::profile::monitoring::sensu::agent

  if $manage_redis {
    include ::profile::database::redis
    Service['redis'] -> Service['sensu-api'] -> Service['sensu-server']
  }

  if $manage_rabbitmq {
    include ::profile::messaging::rabbitmq
    Service['rabbitmq-server'] -> Class['sensu::package']
  }

  if $manage_graphite {
    include ::graphite
  }

  if $manage_firewall {
    profile::firewall::rule { '411 uchiwa accept tcp':
      port        => [80, 3000, 4567],
      destination => $::ipaddress_mgmt1,
      extras      => $firewall_extras,
    }
  }

  $handlers  = hiera_hash('profile::monitoring::sensu::server::handlers', {})
  $filters  = hiera_hash('profile::monitoring::sensu::server::filters', {})
  create_resources('sensu::handler', $handlers)
  create_resources('sensu::filter', $filters)
}
