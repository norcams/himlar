#
class profile::openstack::adminrc(
  $username,
  $password,
  $tenant_name,
  $region_name,
  $auth_url,
  $cacert = undef
  ) {

  file { '/root/keystonerc_admin':
    ensure => file,
    content => template("${module_name}/openstack/keystonerc_admin.erb")
  }

}
