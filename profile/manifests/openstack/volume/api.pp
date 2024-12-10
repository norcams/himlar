class profile::openstack::volume::api(
  $manage_firewall = true,
  $firewall_extras = {},
  $enable_testbackend = false,
){
  include profile::openstack::volume

  include ::cinder::api
  include ::cinder::wsgi::apache
  include ::cinder::glance
  include ::cinder::backends

  if $manage_firewall {
        profile::firewall::rule{ '8776 cinder-api accept tcp':
          dport   => 8776,
          extras => $firewall_extras,
    }
        profile::firewall::rule{ '3260 cinder accept iSCSI':
          dport   => 3260,
          extras => $firewall_extras,
    }
  }

  if $enable_testbackend {
    include ::cinder::setup_test_volume
  } else  {
    create_resources(cinder::backend::rbd, lookup('profile::openstack::volume::backend::rbd', Hash, 'first', {}))
    create_resources(cinder::backend::nfs, lookup('profile::openstack::volume::backend::nfs', Hash, 'first', {}))
  }

  create_resources(cinder_type, lookup('profile::openstack::volume::type', Hash, 'first', ), { require => Class['cinder::wsgi::apache'] })
}
