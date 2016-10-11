#
#
class profile::network::leaf(
  $manage_license     = false,
  $cumulus_license    = "user@example.com|00000000000000000000000000000000000000000000000000\n",
  $manage_quagga      = false,
  $manage_acls        = false,
  $acls               = {},
) {

  # Define: profile::network::leaf::acl
  # 
  # Create cumulus acl files.
  # Pass a hash of filenames with arrays of rules. All rules are optional,
  # but filename must be in the format of 10myrules.rules in order to
  # be meaningful. The two starting digits should be between 01-98, and
  # only files ending with .rules are applied. By passing an array of
  # rule_vars in format of VARIABLE = value you may reuse those variables
  # in the rule arrays.
  define acl (
    $rule_vars        = [],
    $iptables         = [],
    $ip6tables        = [],
    $ebtables         = [],
    $execpath         = '/usr/cumulus/bin',
    $cumulus_acls_dir = '/etc/cumulus/acl/policy.d/',
  ) {
    # Validate arrays
    validate_array($rule_vars)
    validate_array($iptables)
    validate_array($ip6tables)
    validate_array($ebtables)

    file { "${name}":
      ensure   => present,
      mode     => '644',
      owner    => 'root',
      group    => 'root',
      path     => "${cumulus_acls_dir}/${name}",
      content  => template("${module_name}/network/cumulus-acls.erb"),
      notify   => Exec["update-acls-${name}"],
    }

    exec { "update-acls-${name}":
      command     => "${execpath}/cl-acltool -i -n -P ${cumulus_acls_dir}",
      #subscribe   => "${cumulus_acls_dir}/${name}",
      refreshonly => true,
    }
  }

  if $manage_acls {
    create_resources(profile::network::leaf::acl, hiera_hash('profile::network::leaf::acls', {}))
  }

  if $manage_license {
    file { '/tmp/licfile':
      ensure  => file,
      content => $cumulus_license,
    } ->
    cumulus_license { 'cumulus_license':
      src => '/tmp/licfile',
#      Ideally restart switchd, but the service is not defined in our code.
#      notify => Service['switchd']
    }
  }

  if $manage_quagga {
    include quagga
  }

  if $manage_acls {

  }
}
