# Class: profile::base::lvm
#
#
class profile::base::lvm {
  include ::lvm

  create_resources(physical_volume, hiera('profile::base::lvm::physical_volume', {}))
  create_resources(volume_group, hiera('profile::base::lvm::volume_group', {}))
  create_resources(lvm::logical_volume, hiera('profile::base::lvm::logical_volume', {}))
  create_resources(filesystem, hiera('profile::base::lvm::filesystem', {}))
}
