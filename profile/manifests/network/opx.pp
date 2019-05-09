class profile::network::opx(
  $if_1gbit_force   = false,
  $opx_cleanup      = false,
) {

  if $if_1gbit_force {
    # Force to 1gbit without auto-negation
    file {'/usr/local/bin/opx-ethtool-speed.sh':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("${module_name}/network/opx-ethtool-speed.erb")
    } ->
    file { '/etc/systemd/system/opx-ethtool-speed.service':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      seltype => 'systemd_unit_file_t',
      content => "[Service]\r\nExecStart=/usr/local/bin/opx-ethtool-speed.sh\r\n",
      notify  => [
        Exec['systemctl_daemon_reload']
      ],
    } ->
    exec { 'systemctl_daemon_reload':
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }
  }

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


