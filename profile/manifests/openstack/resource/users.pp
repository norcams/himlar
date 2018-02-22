#
# Manage custom users and user roles
#
class profile::openstack::resource::users(
  $users      = {},
  $user_roles = {},
) {

  create_resources('keystone_user', $users)
  create_resources('keystone_user_role', $user_roles)

}
