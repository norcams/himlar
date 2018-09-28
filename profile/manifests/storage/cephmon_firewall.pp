# Class: profile::storage::cephmon_firewall
#
#
class profile::storage::cephmon_firewall(
  $manage_firewall           = false,
  $manage_dashboard_firewall = false,
  $firewall_extras           = {
    'mon_listen'   => {},
    'mgr_listen'   => {},
    'dash_listen'  => {},
  },
) {
  if $manage_firewall {
    profile::firewall::rule { '100 ceph-mon accept tcp':
      dport  => 6789,
      extras => $firewall_extras['mon_listen']
    }
    profile::firewall::rule { '101 ceph-mgr accept tcp':
      dport  => 6800,
      extras => $firewall_extras['mgr_listen']
    }
    if $manage_dashboard_firewall {
      profile::firewall::rule { '102 ceph-dashboard accept tcp':
        dport  => 8443,
        extras => $firewall_extras['dash_listen']
      }
    }
  }
}
