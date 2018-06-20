# Profile class for the nova control node
class profile::openstack::novactrl(
  $enable_api           = false,
  $enable_scheduler     = false,
  $enable_consoleauth   = false,
  $enable_consoleproxy  = false,
  $enable_conductor     = false,
  $manage_quotas        = false,
  $manage_az            = false,
  $manage_firewall      = false,
  $firewall_extras      = {}
) {

  include ::nova
  include ::nova::placement
  include ::nova::config
  include ::nova::network::neutron
  include ::nova::wsgi::apache_placement

  if $enable_scheduler {
    include ::profile::openstack::compute::scheduler
  }

  if $enable_consoleauth {
    include ::profile::openstack::compute::consoleauth
  }

  if $enable_consoleproxy {
    include ::profile::openstack::compute::consoleproxy
  }

  if $enable_conductor {
    include ::profile::openstack::compute::conductor
  }

  if $manage_quotas {
    include ::nova::quota
  }

  if $manage_az {
    include ::nova::availability_zone
  }

  if $manage_firewall {
    profile::firewall::rule { '220 nova-placement-api accept tcp':
      port   => 80,
      extras => $firewall_extras
    }

    profile::firewall::rule { '220 nova-api accept tcp':
      port   => 8774,
      extras => $firewall_extras
    }

    profile::firewall::rule { '220 nova-api-ec2 accept tcp':
      port   => 8773,
      extras => $firewall_extras
    }

  }


}
