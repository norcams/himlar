class profile::application::etcd(
  $manage_firewall = true,
  $firewall_extras = {},
  $etcd_name = lookup('etcd::etcd_name', String, 'first', ''),
  $listen_client_urls = lookup('etcd::listen_client_urls', Array, 'deep', undef),
  $advertise_client_urls = lookup('etcd::advertise_client_urls', Array, 'deep', undef),
  $listen_peer_urls = lookup('etcd::listen_peer_urls', Array, 'deep', undef),
  $initial_advertise_peer_urls = lookup('etcd::initial_advertise_peer_urls', Array, 'deep', undef),
  $initial_cluster = lookup('etcd::initial_cluster', Array, 'deep', undef),
){
  include ::etcd

  file { '/usr/local/sbin/bootstrap-etcd-member':
    ensure  => file,
    content => template("${module_name}/application/etcd/bootstrap-member.erb"),
  }

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
