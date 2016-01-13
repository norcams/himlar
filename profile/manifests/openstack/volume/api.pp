class profile::openstack::volume::api(
  $manage_firewall = true,
  $firewall_extras = {},
){
  include profile::openstack::volume

  include ::cinder::api
  include ::cinder::glance

  if $manage_firewall {
        profile::firewall::rule{ '8776 cinder-api accept tcp':
          port   => 8776,
          extras => $firewall_extras,
    }
        profile::firewall::rule{ '3260 cinder accept iSCSI':
          port   => 3260,
          extras => $firewall_extras,
    }
  }
}
