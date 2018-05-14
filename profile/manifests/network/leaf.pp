#
#
class profile::network::leaf(
  $manage_license     = false,
  $cumulus_license    = "user@example.com|00000000000000000000000000000000000000000000000000\n",
  $manage_quagga      = false,
  $manage_frrouting   = false,
  $manage_acls        = false,
  $manage_portconfig  = false,
  $cumulus_portconfig = {},
) {

  if $manage_acls {
    create_resources(profile::network::leaf::acl, lookup('profile::network::leaf::acls', Hash, 'deep', {}))
  }

  if $manage_license {
    file { '/etc/cumulus/.license':
      ensure  => file,
      content => $cumulus_license,
    }
  }

  if $manage_quagga {
    include quagga
  }

  if $manage_frrouting {
    include frrouting
  }
  if $manage_portconfig {
    create_resources(profile::network::leaf::cumulus_portconfig, lookup('profile::network::leaf::cumulus_portconfigs', Hash, 'deep', {}))
  }
}
