#
# Manage the setup of dataporten auth provider for keystone
#
class profile::openstack::resource::dataporten(
  $manage_dataporten = false
) {

  if $manage_dataporten {
    $domain = lookup('profile::openstack::resource::dataporten::domain', Hash, 'deep', {})
    create_resources('keystone_domain', $domain)

    $idp = lookup('profile::openstack::resource::dataporten::identity_provider', Hash, 'deep', {})
    create_resources('keystone_identity_provider', $idp)
  }



}
