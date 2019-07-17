#
class profile::openstack::object::radosgw(
  $manage_firewall = false,
  $dport = ['7480'],
  $source = "${::network_trp1}/${::netmask_trp1}",
  $keystone = {},
  $rgw = {}
) {

    include ::ceph::profile::client

    if $manage_firewall {
      profile::firewall::rule { '100 ceph radosgw accept tcp':
        dport  => $dport,
        source => $source
      }
    }

    create_resources('ceph::rgw', $rgw)
    create_resources('ceph::rgw::keystone', $keystone)

}
