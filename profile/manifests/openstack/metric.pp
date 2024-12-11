#
# Setup metric role with gnocchi
#
class profile::openstack::metric (
  $manage_firewall   = false,
  $manage_wsgi       = false,
  $metric_ports      = ['8041'],
  $firewall_extras   = {},
  $gnocchi_path      = '/var/lib/gnocchi',
  $gnocchi_owner     = 'gnocchi',
  $gnocchi_group     = 'gnocchi',
)  {

  include ::gnocchi
  include ::gnocchi::config
  include ::gnocchi::db
  include ::gnocchi::api

  # wrappe disse i "manage_"-variabler
  include ::gnocchi::client
  include ::gnocchi::metricd
  include ::gnocchi::storage
  include ::gnocchi::storage::file
  include ::gnocchi::statsd
  include ::gnocchi::cors

  if $manage_wsgi {
    include ::gnocchi::wsgi::apache
  }

  # This will make sure httpd service will be restarted on config changes
  Gnocchi_config <| |> ~> Class['apache::service']

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

  # Ensure top directory/mountpoint is owned by gnocchi
  file  { 'gnocchi_dir':
    path  => $gnocchi_path,
    owner => $gnocchi_owner,
    group => $gnocchi_group,
  }
}
