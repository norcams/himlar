# Profile code to enable telegraf

class profile::monitoring::telegraf(
  $enable_telegraf = false,
  $merge_strategy = 'deep',
  $run_in_vrf = false,
  $use_http_proxy = false,
  $http_proxy
  ) {

  if $enable_telegraf {
    include ::telegraf

    $defaults = { 'ensure' => present }

    # inputs
    $inputs = lookup('profile::monitoring::telegraf::inputs', Hash, $merge_strategy, {})
    create_resources(telegraf::input, $inputs, $defaults)

    # outputs
    $outputs = lookup('profile::monitoring::telegraf::outputs', Hash, $merge_strategy, {})
    create_resources(telegraf::output, $outputs, $defaults)
    if $use_http_proxy {
      file { '/etc/default/telegraf':
        ensure => present,
        mode   => '0755',
        owner  => 'root',
        content => template("${module_name}/monitoring/telegraf/default.erb"),
      }
    }
    # this is used for cumulus linux (debian)
    # the override file must be loaded last so we rename it zzoverride.conf
    if $run_in_vrf {

      file { '/etc/systemd/system/telegraf.service.d':
        ensure => 'directory'
      }
      file { 'telegraf-systemd-override':
        ensure => file,
        path   => '/etc/systemd/system/telegraf.service.d/zzoverride.conf',
        owner  => root,
        group  => root,
        source => "puppet:///modules/${module_name}/monitoring/telegraf/systemd/override.conf",
        notify => [Exec['telegraf_debian_systemctl_daemon_reload'], Service['telegraf']]
      }

      exec { 'telegraf_debian_systemctl_daemon_reload':
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
      }
    }
  }

}
