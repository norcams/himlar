# Class: profile::base::nfs
#
#
class profile::base::nfs (
  $create_share     = false,
  $share            = {},
  $options          = undef,
  $manage_firewall  = false,
  $mount_fwsettings = {},
){
  if $create_share {
    include nfs::server

    create_resources(nfs::export, lookup('profile::base::nfs::shares', Hash, 'first', {}))
  }

  if $manage_firewall {
      profile::firewall::rule { '234 NFSv4 mount tcp':
        port   => 2049,
        extras => $mount_fwsettings,
      }

  }
}

