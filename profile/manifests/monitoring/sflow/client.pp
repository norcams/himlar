#
class profile::monitoring::sflow::client (
  $manage_service        = false,
  $hsflowd_template      = 'hsflowd_spine.conf.erb',
  $sflow_collector       = undef,
) {

  file { 'hsflowd.conf':
    ensure  => file,
    path    => '/etc/hsflowd.conf',
    content => template("${module_name}/monitoring/sflow/${hsflowd_template}"),
    mode    => '0644',
  }

  if $manage_service {
    service { 'hsflowd':
      ensure => running,
      enable => true
    }
  }
}
