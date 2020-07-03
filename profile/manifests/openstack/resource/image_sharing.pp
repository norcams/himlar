# Manage project user for sharing images
class profile::openstack::resource::image_sharing(
  $manage  = false,
  $ensure  = present,
  $project = 'nrec-images'
  $domain  = 'default'
) {

  if $manage {
    keystone_tenant { $project::$domain:
      ensure      => $ensure,
      enabled     => true,
      description => "Project for sharing images",
    }
  }

}
