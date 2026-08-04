#
class profile::openstack::compute::pci_passthrough(
  $manage_pci_whitelist  = false,
  $configure_intel_iommu = false,
  $configure_amd_iommu   = false,
  $configure_iommu_pt    = false,
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

## Probably set as default when enabling iommu in BIOS, this is more for clarity  
  if $configure_amd_iommu {
    # Set option in grub2
    kernel_parameter { 'amd_iommu':
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

## Optmization option when using pci passthrough, take into account DMA protection before enabling
  if $configure_iommu_pt {
    # Set option in grub2
    kernel_parameter { 'iommu':
      ensure => present,
      value  => 'pt',
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
