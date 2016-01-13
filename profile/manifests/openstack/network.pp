class profile::openstack::network(
  $l2_driver = 'ovs',
  $plugin    = 'ml2',
  $manage_firewall = true,
  $firewall_extras = {},
){
  include ::neutron

  case $plugin {
    'ml2': {
      include "::neutron::plugins::${plugin}"
      case $l2_driver {
        'calico': {
          include ::profile::openstack::network::calico
        }
        default : {
          include "::neutron::agents::ml2::${l2_driver}"
        }
      }
    }
    default: {
      include "::neutron::plugins::${plugin}"
      include "::neutron::agents::${plugin}"
    }
  }

  if $manage_firewall {
    case $l2_driver {
      'ovs': {
        profile::firewall::rule { '223 tunnelling accept gre':
          port   => undef,
          proto  => 'gre',
          extras => $firewall_extras,
        }
      }
      default: {}
    }
  }

}
