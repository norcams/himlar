<<<<<<< HEAD
# Manage project for sharing images
=======
# Manage project user for sharing images
>>>>>>> 69b427ded23622675b7e92dd417c03bbc7e91e1c
class profile::openstack::resource::image_sharing(
  $manage  = false,
  $ensure  = present,
  $project = 'nrec-images'
<<<<<<< HEAD
  $domain  = 'dataporten'
=======
  $domain  = 'default'
>>>>>>> 69b427ded23622675b7e92dd417c03bbc7e91e1c
) {

  if $manage {
    keystone_tenant { $project::$domain:
      ensure      => $ensure,
      enabled     => true,
      description => "Project for sharing images",
    }
  }

}
