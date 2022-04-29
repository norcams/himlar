#
class profile::application::postfix (
  $relayhost        = undef,
  $myhostname       = $::fqdn,
  $manage_postfix   = false,
  $manage_firewall  = true,
  $mynetworks       = "${::network_mgmt1}/${::cidr_mgmt1}",
  $inet_interfaces  = $::ipaddress_mgmt1,
  $packages         = ['postfix'],
  $service_name     = 'postfix'
) {

  if $manage_postfix {

    package { $packages: }

    service { $service_name:
      ensure => running,
      enable => true
    }

    unless empty($relayhost) {
      file_line { 'main.cf_relayhost':
        ensure => present,
        path   => '/etc/postfix/main.cf',
        line   => "relayhost = ${relayhost}",
        match  => '^relayhost\ \=',
        notify => Service[$service_name]
      }
    }
    file_line { 'main.cf_mynetworks':
      ensure => present,
      path   => '/etc/postfix/main.cf',
      line   => "mynetworks = ${mynetworks}",
      match  => '^mynetworks\ \=',
      notify => Service[$service_name]
    }
    file_line { 'main.cf_myhostname':
      ensure => present,
      path   => '/etc/postfix/main.cf',
      line   => "myhostname = ${myhostname}",
      match  => '^myhostname\ \=',
      notify => Service[$service_name]
    }
    file_line { 'main.cf_inet_interfaces':
      ensure => present,
      path   => '/etc/postfix/main.cf',
      line   => "inet_interfaces = ${inet_interfaces}",
      match  => '^inet_interfaces\ \=',
      notify => Service[$service_name]
    }
    if $manage_firewall {
      profile::firewall::rule { '180 smtp allow':
        dport  => 25,
        source => "${::network_mgmt1}/${::netmask_mgmt1}",
      }
    }
  }
}
