#
class profile::openstack::openrc(
  $username,
  $password,
  $project_name,
  $region_name,
  $auth_url,
  $compute_api_version,
  $project_domain_name = 'Default',
  $interface = 'admin',
  $user_domain_name = 'Default',
  $cacert = undef,
  $filename = '/root/openrc'
  ) {

  file { $filename:
    ensure  => file,
    content => template("${module_name}/openstack/openrc.erb")
  }

}
