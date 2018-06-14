#
class profile::openstack::compute::placement(
  $manage_firewall = false,
  $firewall_extras = {}
) {

  include ::nova
  include ::nova::placement

  #  if $manage_firewall {
  #    profile::firewall::rule { '220 nova-api accept tcp':
  #      port   => 8774,
  #      extras => $firewall_extras
  #    }
  #
  #    profile::firewall::rule { '220 nova-api-ec2 accept tcp':
  #      port   => 8773,
  #      extras => $firewall_extras
  #    }
  #
  #  }
}
