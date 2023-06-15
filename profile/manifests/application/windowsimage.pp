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
    package { 'packer':
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
    file { $build_root:
      ensure => directory,
      mode   => '0755',
      owner  => $user,
      group  => $group
    }
    file { "/home/${user}/.ssh":
      ensure => directory,
      mode   => '0644',
      owner  => $user,
      group  => $group
    }
    file { "/home/${user}/.ssh/authorized_keys":
      ensure  => present,
      mode    => '0644',
      owner   => $user,
      group   => $group,
      content => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDO+pF/Ef8CE0E+56I3lixPHnNowQatNrJ31+Jds5gbEAA13BZeckPhcOkMWIJX+54gf16tbL1olRS7bwbaub+xd9IoXmiDaYfXxq634mYcDbKvbXRYBmBDx6n9+74dhPBzcsli0cQpNCGJvIH0blqprdEgxRPdAnJYuRxK4hOT7LZsgmM+y6PDZxJ+96jDtJsU7Jks8g7wZ1/x380GTE64K0RaperXCs77x5Zky6934aZu1HyPi2EN+4am5MMnwNA6A60j5V8DGoA56G7l47QY5Eb3G4r6XgCS+hemimjr5US/pcZuE38TpbGZHCxH4dqS68umwE6iw/FDNCyR/WmJLCxt9IM+l/hVNtNYyClt8uFBgLGwFX9JNd3JUKJwwl3uiyO79I1CzCx8sjbhX3TrXqqAfGuyEzwo5BRO2kfDiZQC5sTPFXTiKwiVv5SrCjKMrkPgPHmWA47a8Rr+86mHRe0j6wwTq3G7Pm4mT86goZY4mrjZ6oexa6unDKymQS0vEsk4ujIMIM3JkkDy5/velzo8toCKNf6gv4YrJ9lKMhnlojqtJP6FrNYTx/Imq8uDTgrj1sq593elaDV9vvft0zn37uIBpq+9WDfxd+EOvRgJ8rY5Qd6OOYoYkMzB9DcHH1blYge9tl1g/qTuFTHEU0fNrJDqmsH72nNBejQNUw=='
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
      source => $virtio_src,
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

