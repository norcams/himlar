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
  $slack_webhook_url,
  $slack_channel,
  $slack_user,
  $twitter_api_key,
  $twitter_api_secret_key,
  $twitter_access_token,
  $twitter_secret_token,
  $status_url,
  $status_token,
  $sensu_url,
  $sensu_username,
  $sensu_password,
  $sensugo_url,
  $sensugo_username,
  $sensugo_password,
  $sensugo_ca_path,
  $domain,
  $mq_host,
  $mq_username,
  $mq_password,
  $mq_vhost,
  $report_db_uri,
  $clistate_db_uri,
  $db_host_nova,
  $db_password_nova,
  $compute_api_version,
  $volume_api_version,
  $ldap_server = undef,
  $ldap_base_dn = undef,
  $cacert = undef
) {

  info($compute_api_version)

  file { '/etc/himlarcli':
    ensure => directory
  }
  -> file { '/etc/himlarcli/config.ini':
    ensure  => file,
    content => template("${module_name}/application/himlarcli/config.ini.erb"),
  }
  -> file { '/etc/himlarcli/clouds.yaml':
    ensure  => file,
    content => template("${module_name}/application/himlarcli/clouds.yaml.erb"),
  }

}
