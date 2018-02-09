class profile::application::etcd(
  $manage_firewall = true,
  $firewall_extras = {},
){
  include ::etcd

  if $manage_firewall {
        profile::firewall::rule{ '2379 etcd client accept tcp':
          dport  => 2379,
          extras => $firewall_extras,
    }
        profile::firewall::rule{ '2380 etcd server accept tcp':
          dport  => 2380,
          extras => $firewall_extras,
    }
  }
}
