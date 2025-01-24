# Profile class for the nova control node
class profile::openstack::novactrl(
  $enable_api           = false,
  $enable_scheduler     = false,
  $enable_conductor     = false,
  $manage_cells         = false,
  $manage_az            = false,
  $manage_firewall      = false,
  $manage_nova_config   = false,
  $firewall_extras      = {},
  $manage_osprofiler = false,
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
  include ::nova::network::neutron
  include ::nova::cinder
  include ::nova::wsgi::apache_api
  include ::nova::logging
  include ::nova::placement
  include ::nova::keystone::service_user

  include ::placement
  include ::placement::db
  include ::placement::api
  include ::placement::wsgi::apache
  include ::placement::logging
  include ::placement::keystone::authtoken

  if $manage_nova_config {
    $default_nova_config = lookup('profile::openstack::novactrl::default_nova_config', Hash, 'deep', {})
    create_resources('nova_config', $default_nova_config)
  }

  # This will make sure httpd service will be restarted on config changes
  Nova_config <| |> ~> Class['apache::service']

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

  if $manage_osprofiler {
    include ::nova::deps
    $osprofiler_config = lookup('profile::logging::osprofiler::osprofiler_config', Hash, 'first', {})
    create_resources('nova_config', $osprofiler_config)
  }
}
