#
class profile::openstack::compute::pci_passthrough(
  $manage_pcipassthrough = false,
) {

if $manage_pcipassthrough {
  include ::nova::pci
}
