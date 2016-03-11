class profile::openstack::volume::api(
  $manage_firewall = true,
  $firewall_extras = {},
  $enable_multibackend = false,
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

  if $enable_multibackend {
    include cinder::backends

    create_resources(cinder::backend::rbd, hiera('profile::openstack::volume::backend::rbd', {}))
    create_resources(cinder::type, hiera('profile::openstack::volume::type', {}))
  } else {
    include ::cinder::setup_test_volume
  }
}
