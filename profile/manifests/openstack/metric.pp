#
# Setup metric role with gnocchi
#
class profile::openstack::metric (
  $manage_firewall   = false,
  $manage_wsgi       = false,
  $metric_ports      = ['8041'],
  $firewall_extras   = {},
)  {

  include ::gnocchi
  include ::gnocchi::config
  include ::gnocchi::api

  # wrappe disse i "manage_"-variabler
  include ::gnocchi::client
  include ::gnocchi::metricd
  include ::gnocchi::storage
  include ::gnocchi::storage::file
  include ::gnocchi::statsd

  if $manage_wsgi {
    include ::gnocchi::wsgi::apache
  }

  if $manage_firewall {
    profile::firewall::rule { '123 metric api accept tcp':
      dport  => $metric_ports,
      proto  => 'tcp',
      extras => $firewall_extras,
    }
    profile::firewall::rule { '124 metricd accept udp':
      dport  => 8125,
      proto  => 'udp',
      extras => $firewall_extras,
    }
  }
}
