#
class profile::openstack::compute::pci_passthrough(
  $manage_pci_alias      = false,
  $manage_pci_whitelist  = false,
  $configure_intel_iommu = false,
  $manage_pcipassthrough = false,
) {

  if $configure_intel_iommu {
    # Set option in grub2
    kernel_parameter { 'intel_iommu':
      ensure => present,
      value  => 'on',
    }
  }

  if $manage_pcipassthrough {
    include ::nova::pci
  }

  if $manage_pci_whitelist {
    include ::nova::compute::pci
  }
}
