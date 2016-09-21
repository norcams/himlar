#
# Manage the setup of dataporten auth provider for keystone
#
class profile::openstack::resource::dataporten(
  $manage_dataporten = false
) {

  if $manage_dataporten {
    $domain = hiera_hash('profile::openstack::resource::dataporten::domain', {})
    create_resources('keystone_domain', $domain)

    $idp = hiera_hash('profile::openstack::resource::dataporten::identity_provider', {})
    create_resources('keystone_identity_provider', $idp)
  }



}
