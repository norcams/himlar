#
# Set parameters for ceph pools
#
define profile::storage::cephpool_params (
  $replicas_num         = undef,
  $replicas_min_size    = undef,
  $crush_rule           = undef,
) {
  require ::ceph::profile::client

  if $replicas_num {
    exec { "set_osd_pool_replicas_num-${name}":
      command     => "ceph osd pool set ${name} size ${replicas_num} && touch /var/lib/ceph/.${name}-replicas_num-created",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates     => "/var/lib/ceph/.${name}-replicas_num-created",
    }
  }
  if $replicas_min_size {
    exec { "set_osd_pool_replicas_min_size-${name}":
      command     => "ceph osd pool set ${name} min_size ${replicas_min_size} && touch /var/lib/ceph/.${name}-replicas_min_size-created",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates     => "/var/lib/ceph/.${name}-replicas_min_size-created",
    }
  }
  if $crush_rule {
    exec { "set_osd_crush_rule-${name}":
      command     => "ceph osd pool set ${name} crush_rule ${crush_rule} && touch /var/lib/ceph/.${name}-crush_rule-created",
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates     => "/var/lib/ceph/.${name}-crush_rule-created",
    }
  }
}
