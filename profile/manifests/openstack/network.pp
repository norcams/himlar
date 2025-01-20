class profile::openstack::network(
  $l2_driver = 'ovs',
  $plugin    = 'ml2',
  $manage_firewall = true,
  $manage_quotas   = false,
  $firewall_extras = {},
  $manage_osprofiler = false,
){
  include ::neutron
  include ::neutron::wsgi::apache

# Use value ml2 for plugin and calico driver for calico v1.3 and older
# then set neutron::core_plugin to neutron.plugins.ml2.plugin.Ml2Plugin
# Use value calico for plugin for calico v1.4 and newer. l2_driver flag will be ignored
# then set neutron::core_plugin to calico
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
    'calico':{
      include ::profile::openstack::network::calico
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

  if $manage_quotas {
    include neutron::quota
  }

  if $manage_osprofiler {
    include ::neutron::deps
    $osprofiler_config = lookup('profile::logging::osprofiler::osprofiler_config', Hash, 'first', {})
    create_resources('neutron_config', $osprofiler_config)
  }
}
