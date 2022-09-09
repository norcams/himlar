#
class profile::openstack::compute::pci_passthrough(
  $manage_pci_whitelist  = false,
  $configure_intel_iommu = false,
  $manage_pcipassthrough = false,
  $efi_workaround        = false, #FIXME - remove when the Foreman chainloads almalinux
) {

  if $configure_intel_iommu {
    # Set option in grub2
    kernel_parameter { 'intel_iommu':
      ensure => present,
      value  => 'on',
    }
    if $efi_workaround and ($::operatingsystem == 'AlmaLinux') {
      exec { 'efi_workaround_refresh':
        command     => 'rsync -Hav /boot/efi/EFI/almalinux/* /boot/efi/EFI/centos/',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        unless      =>  [ 'grep iommu /boot/efi/EFI/centos/grub.cfg'  ],
      }
    }
  }

  if $manage_pcipassthrough {
    include ::nova::pci
  }

  if $manage_pci_whitelist {
    include ::nova::compute::pci
  }
}
