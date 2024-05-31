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
  include ::neutron::server::notifications::nova
#  include ::neutron::wsgi::apache
  include ::neutron::config
  include ::neutron::logging

  create_resources('neutron_config', $neutron_config)

  if $manage_neutron_policies {
    include ::neutron::policy
  }

  if $neutron_nova_insecure {
    neutron_config {
      'nova/insecure': value => 'True';
    }
  }

  if $manage_firewall {
    firewall { '210 neutron-server accept tcp':
      proto    => 'tcp',
      dport    => 9696,
      action   => 'accept',
      state    => ['NEW'],
      source   => '0.0.0.0/0',
      chain    => 'INPUT',
      provider => 'iptables'
    }
  }
}
