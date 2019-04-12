#
class profile::openstack::compute::pci_passthrough(
  $manage_pci_alias =     false,
  $manage_pci_whitelist = false,
) {

  if $manage_pcipassthrough {
    include ::nova::pci
  }

  if $manace_pci_whitelist {
  	include ::nova::compute::pci
  }
}
