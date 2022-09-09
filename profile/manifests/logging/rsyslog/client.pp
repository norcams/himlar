# rsyslog client for Openstack
class profile::logging::rsyslog::client(
  $manage_rsyslog = false,
  $modules        = {},
  $global_config  = {},
  $legacy_config  = {},
  $inputs         = {},
) {

  if $manage_rsyslog {
    class { 'rsyslog::config' :
      modules       => $modules,
      global_config => $global_config,
      legacy_config => $legacy_config,
      inputs        => $inputs,
    }
  }

}
