#
class profile::openstack::network::controller(
  $manage_neutron_policies = true,
  $neutron_policy_path = '/etc/neutron/policy.json',
  $neutron_nova_insecure = false,
  $neutron_config = {},
  $manage_firewall = true,
  $firewall_extras = {}
) {
  include profile::openstack::network

  include ::neutron::server
  include ::neutron::server::notifications

  create_resources('neutron_config', $neutron_config)

  if $manage_neutron_policies {
    Openstacklib::Policy::Base {
      file_path => $neutron_policy_path,
    }
    $policy = hiera('profile::openstack::network::policies', {})
    create_resources('openstacklib::policy::base', $policy)
                #{ require => Class[::neutron::server] })
  }

  if $neutron_nova_insecure {
    neutron_config {
      'nova/insecure': value => 'True';
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '210 neutron-server accept tcp':
      port   => 9696,
      extras => $firewall_extras,
    }
  }
}
