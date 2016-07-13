#
# Manage the setup of dataporten auth provider for keystone
#
class profile::openstack::resource::dataporten(
  $manage_dataporten = false
) {

  if $manage_dataporten {
    $domain = hiera_hash('profile::openstack::dataporten::domain', {})
    create_resources('keystone_domain', $domain)
  }

}
