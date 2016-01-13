class profile::openstack::compute::api(
  $manage_firewall = true,
  $firewall_extras = {}
) {
  include ::profile::openstack::compute
  include ::nova::api

  if $manage_firewall {
    profile::firewall::rule { '220 nova-api accept tcp':
      port   => 8774,
      extras => $firewall_extras
    }

    profile::firewall::rule { '220 nova-api-ec2 accept tcp':
      port   => 8773,
      extras => $firewall_extras
    }

    profile::firewall::rule { '220 nova-api-metadata accept tcp':
      port   => 8775,
      extras => $firewall_extras
    }
  }
}
