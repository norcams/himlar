# Manage project for sharing images
class profile::openstack::resource::image_sharing(
  $manage  = false,
  $ensure  = present,
  $project = 'nrec-images',
  $domain  = 'dataporten'
) {

  if $manage {
    keystone_tenant { $project:
      ensure      => $ensure,
      enabled     => true,
      domain      => $domain,
      description => "Project for sharing images",
    }
  }

}
