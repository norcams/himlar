# Class: profile::base::cl_limits
#
#
class profile::base::cl_limits (
  $manage_cl_limits = false,
  $as_value = 1048576,
){
  if $manage_cl_limits {
    file { '/etc/security/limits.d/99-cumulus.conf':
      ensure => present,
    }->
    file_line { 'Set address space value':
      path  => '/etc/security/limits.d/99-cumulus.conf',
      line  => "1: soft as ${as_value}",
      match => '^1\:.*soft.*as.*[0-9]',
    }
  }
}
