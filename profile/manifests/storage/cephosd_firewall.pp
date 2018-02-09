# Class: profile::storage::cephosd_firewall
#
#
class profile::storage::cephosd_firewall(
  $manage_firewall = false,
  $firewall_extras = {
    'osd_listen'   => {},
  },
) {
  if $manage_firewall {
    profile::firewall::rule { '101 ceph-osd accept tcp':
      dport  => ['6800-6860'],
      extras => $firewall_extras['osd_listen']
    }
  }
}
