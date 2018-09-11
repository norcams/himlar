# Class: profile::storage::cephmds
#
#
class profile::storage::cephmds (
  $manage_firewall = false,
  $firewall_extras = {
    'mds_listen'   => {},
  },
) {

  include ::ceph::profile::client
  include ::ceph::profile::mds

  if $manage_firewall {
    profile::firewall::rule { '100 ceph-mds accept tcp':
      dport  => ['6800-7300'],
      extras => $firewall_extras['mds_listen']
    }
  }
}
