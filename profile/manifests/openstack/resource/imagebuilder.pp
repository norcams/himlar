# Manage imagebuilder user and project
class profile::openstack::resource::imagebuilder(
  $password,
  $manage  = false,
  $ensure  = present,
  $user    = 'imagebuilder',
  $project = 'imagebuilder',
  $domain  = 'Default'
) {

  if $manage {
    keystone_user { $user:
      ensure   => $ensure,
      enabled  => true,
      password => $password
    }
    -> keystone_tenant { $project:
      ensure      => $ensure,
      enabled     => true,
      description => "project for ${user}",
      domain      => $domain
    }
    -> keystone_user_role { "${user}@${project}":
      ensure => $ensure,
      roles  => 'user',
    }
  }

}
