# Manage config file for himlar cli
class profile::application::himlarcli(
  $username,
  $password,
  $tenant_name,
  $default_domain,
  $region_name,
  $auth_url,
  $service_net,
  $foreman_url,
  $foreman_password,
  $foreman_user,
  $smtp,
  $from_addr,
  $domain,
  $ldap_server = undef,
  $ldap_base_dn = undef,
  $cacert = undef
) {

  file { '/etc/himlarcli':
    ensure => directory
  } ->
  file { '/etc/himlarcli/config.ini':
    ensure => file,
    content => template("${module_name}/application/himlarcli/config.ini.erb"),
  }
}
