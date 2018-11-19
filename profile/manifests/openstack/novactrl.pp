# Profile class for the nova control node
class profile::openstack::novactrl(
  $enable_api           = false,
  $enable_scheduler     = false,
  $enable_conductor     = false,
  $manage_cells         = false,
  $manage_az            = false,
  $manage_firewall      = false,
  $firewall_extras      = {}
) {

  if $manage_firewall {
    profile::firewall::rule { '220 nova-placement-api accept tcp':
      dport  => 8778,
      extras => $firewall_extras
    }

    profile::firewall::rule { '220 nova-api accept tcp':
      dport  => 8774,
      extras => $firewall_extras
    }

    profile::firewall::rule { '220 nova-api-ec2 accept tcp':
      dport  => 8773,
      extras => $firewall_extras
    }

  }

  include ::nova
  include ::nova::api
  include ::nova::config
  include ::nova::placement
  include ::nova::network::neutron
  include ::nova::wsgi::apache_api
  include ::nova::wsgi::apache_placement

  if $manage_cells {
    # This should be fine to do even after the cells are setup:
    # https://docs.openstack.org/nova/pike/cli/nova-manage.html#man-page-cells-v2
    include ::nova::cell_v2::simple_setup
  }

  if $enable_scheduler {
    include ::profile::openstack::compute::scheduler
  }

  if $enable_conductor {
    include ::profile::openstack::compute::conductor
  }

  if $manage_az {
    include ::nova::availability_zone
  }

}
