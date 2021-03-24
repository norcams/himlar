# Class: profile::base::disk
#
#
class profile::base::disk (
  $manage_hdparm = false,
  $disk_hdparams = {},
){
  if $manage_hdparm {
    create_resources(profile::base::hdparm, $disk_hdparams, {})
  }
}
