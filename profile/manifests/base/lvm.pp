# Class: profile::base::lvm
#
#
class profile::base::lvm {
  include ::lvm

  create_resources(physical_volume, lookup('profile::base::lvm::physical_volume', Hash, 'first', {}))
  create_resources(volume_group, lookup('profile::base::lvm::volume_group', Hash, 'first', {}))
  create_resources(lvm::logical_volume, lookup('profile::base::lvm::logical_volume', Hash, 'first', {}))
  create_resources(filesystem, lookup('profile::base::lvm::filesystem', Hash, 'first', {}))
}
