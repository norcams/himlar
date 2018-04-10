# Manage config file for himlar cli
class profile::application::himlarcli(
  $username,
  $password,
  $tenant_name,
  $default_domain,
  $region_name,
  $auth_url,
  $statsd_server,
  $foreman_url,
  $foreman_password,
  $foreman_user,
  $smtp,
  $from_addr,
  $domain,
  $mq_host,
  $mq_username,
  $mq_password,
  $mq_vhost,
  $ldap_server = undef,
  $ldap_base_dn = undef,
  $cacert = undef
) {

  file { '/etc/himlarcli':
    ensure => directory
  } ->
  file { '/etc/himlarcli/config.ini':
    ensure  => file,
    content => template("${module_name}/application/himlarcli/config.ini.erb"),
  } ->
  file { '/etc/himlarcli/clouds.yaml':
    ensure  => file,
    content => template("${module_name}/application/himlarcli/clouds.yaml.erb"),
  }

}
