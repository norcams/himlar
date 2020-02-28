# Define: profile::network::ipsec::tunnel
# 
# Create IPsec tunnel.
define profile::network::ipsec::tunnel (
  $left             = undef,
  $right            = undef,
  $authby           = "secret",
  $auto             = "add", # Use "start" for production tunnels
  $config_dir       = '/etc/ipsec.d',
  $phase2alg        = undef,
  $dpdaction        = undef,
  $dpddelay         = undef,
  $dpdtimeout       = undef,
  $ike              = undef,
  $ikev2            = undef,
  $ikelifetime      = undef,
  $leftsubnet       = undef,
  $leftvti          = undef,
  $rightsubnet      = undef,
  $mark             = undef,
  $vti_interface    = undef,
  $vti_routing      = undef,
  $pfs              = undef,
  $salifetime       = undef,
  $type             = undef,
  $psk              = undef,
) {

  # Preshared key kan be given as $psk in original hash, og given as secret with
  # the variable name psk-${name-of-tunnel}
  unless $psk {
    $psk_real = lookup("profile::network::ipsec::tunnel::psk-${name}", Data, 'deep')
  } else {
    $psk_real = $psk
  }

  file { "${name}.secrets":
    ensure   => present,
    mode     => '0600',
    owner    => 'root',
    group    => 'root',
    path     => "${config_dir}/${name}.secrets",
    content  => template("${module_name}/network/ipsec_secret.erb"),
    notify   => Service['ipsec']
  }
  file { "${name}.conf":
    ensure   => present,
    mode     => '0600',
    owner    => 'root',
    group    => 'root',
    path     => "${config_dir}/${name}.conf",
    content  => template("${module_name}/network/ipsec_tunnel.erb"),
    notify   => Service['ipsec']
  }
}
