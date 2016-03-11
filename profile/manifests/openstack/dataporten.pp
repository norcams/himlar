class profile::openstack::dataporten() {

  $domain = hiera_hash('profile::openstack::dataporten::domain', {})
  create_resources('keystone_domain', $domain)

  #$identity_provider = hiera_hash('profile::openstack::dataporten::identity_provider', {})
  #create_resources('keystone_identity_provider', $identity_provider)

}
