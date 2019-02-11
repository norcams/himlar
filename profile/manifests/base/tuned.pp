# Class for tuned
#
# Takes two parameters:
#   manage_tuned  - boolean to turn on the management of tuned (default: false)
#   tuned_profile - which tuned profile to set (default: undef)
#
# Author: trond
#
class profile::base::tuned (
  $manage_tuned  = false,
  $tuned_profile = undef,
){

  if $manage_tuned {
    # ensure that the package is installed
    package { 'tuned':
      ensure => 'present',
    }

    # ensure that the service enabled and running
    service { 'tuned':
      ensure => true,
      enable => true,
      require => Package['tuned'],
    }

    # set the tuned profile
    exec { 'set_tuned_profile':
      command => "/usr/sbin/tuned-adm profile ${tuned_profile}",
      unless  => "/usr/bin/grep -q ${tuned_profile} /etc/tuned/active_profile",
    }

  }
}
