# Manage imagebuilder user and project
class profile::openstack::resource::imagebuilder(
  $password,
  $manage  = false,
  $ensure  = present,
  $user    = 'imagebuilder',
  $project = 'imagebuilder',
  $domain  = 'default'
) {

  if $manage {
    keystone_user { $user:
      ensure   => $ensure,
      enabled  => true,
      password => 'imagebuilder_pass'
    } ->
    keystone_tenant { $project:
      ensure      => $ensure,
      enabled     => true,
      description => "project for ${user}",
    } ->
    keystone_user_role { "${user}@${project}":
      ensure => $ensure,
      roles  => 'user',
    }
  }

}
