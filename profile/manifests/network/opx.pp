class profile::network::opx(
  $opx_cleanup      = false,
) {

  # What were they thinking...
  if $opx_cleanup {
    file { 'remove-eth0':
      ensure => 'absent',
      path   => '/etc/network/interfaces.d/eth0',
    }
    # they even configured the interfaces file...
    file { 'opx-interfaces':
      ensure  => file,
      path    => '/etc/network/interfaces',
      content => "# interfaces(5) file used by ifup(8) and ifdown(8)\r\n# Include files from /etc/network/interfaces.d:\r\n\r\nsource /etc/network/interfaces.d/*.cfg\r\n"
    }
  }

}
