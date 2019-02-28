#
class profile::openstack::object::radosgw(
  $manage_firewall = false,
  $dport = ['7480'],
  $source = "${::network_trp1}/${::netmask_trp1}",
  $keystone = {}
) {

    include ::ceph::profile::client
    include ::ceph::profile::rgw

    if $manage_firewall {
      profile::firewall::rule { '100 ceph radosgw accept tcp':
        dport  => $dport,
        source => $source
      }
    }

    create_resources('ceph::rgw::keystone', $keystone)

}
