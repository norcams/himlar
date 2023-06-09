# Infrastructure for building windows images with packer and qemu
class profile::application::windowsimage(
  $enable          = false,
  $user            = 'windowsbuilder',
  $group           = 'windowsbuilder',
  $build_root      = '/var/lib/libvirt/images/windows_builder',
  $virtio_src      = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso',
  $vmbios_src      = 'https://iaas-repo.uio.no/nrec/nrec-resources/files/win_image/',
  $manage_firewall = false,
  $firewall_extras = {},
  $firewall_ports  = ['5998-5999']
) {

  if $enable {

    package { 'git':
      ensure   => installed
    }
    group { $group:
      ensure => present
    } ->
    user { $user:
      ensure     => present,
      managehome => true,
      gid        => $group,
    } 
    file { "${build_root}":
      ensure => directory,
      mode   => '0755',
      owner  => $user,
      group  => $group
    }
    vcsrepo { "${build_root}/packer-windows":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/norcams/packer-windows.git',
      owner    => $user,
      group    => $group
    }
    file{ "${build_root}/virtio-win.iso":
      ensure => file,
      source => "${virtio_src}",
      owner  => $user,
      group  => $group
    }
    file{ "${build_root}/OVMF_CODE.fd":
      ensure => file,
      source => "${vmbios_src}OVMF_CODE.fd",
      owner  => $user,
      group  => $group
    }
    file{ "${build_root}/OVMF_VARS.fd":
      ensure => file,
      source => "${vmbios_src}OVMF_VARS.fd",
      owner  => $user,
      group  => $group
    }
  }

# Install packer from repo

# Serve the building process over vnc
if $manage_firewall and $enable {
    profile::firewall::rule { '253 accept qemu vnc':
      dport  => $firewall_ports,
      extras => $firewall_extras
    }
  }
}

