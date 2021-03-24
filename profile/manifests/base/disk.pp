# Class: profile::base::disk
#
#
class profile::base::disk (
  $manage_hdparm = false,
  $disk_hdparams = {},
){
  if $manage_hdparm {
    package { 'hdparm':
      ensure => installed,
    }
    create_resources(profile::base::hdparm, $disk_hdparams, {})
  }
}
