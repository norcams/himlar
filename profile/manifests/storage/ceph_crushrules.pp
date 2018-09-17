#
# Create rule sets for ceph crush
#
define profile::storage::ceph_crushrules (
  $rule_type           = "replicated",
  $rule_root           = "default",
  $rule_failure_domain = "host",
  $rule_device_type    = "hdd",
) {

  exec { "create_ceph_crushrule-${name}":
    command     => "ceph osd crush rule create-${rule_type} ${name} ${rule_root} ${rule_failure_domain} ${rule_device_type} && touch /var/lib/ceph/.${name}-crushrule-created",
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    creates     => "/var/lib/ceph/.${name}-crushrule-created",
  }
}
