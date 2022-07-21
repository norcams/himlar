#
# For NVIDIA vGPU cards utilizing SR-IOV, like Ampere, the mdevs are not created
# at boot time. We need to create the mdevs at every boot
#

class profile::openstack::compute::nvidia_vgpu_createmdev(
  $enable = false,
) {

  if $enable {
    file { '/etc/systemd/system/create-nvidia-mdev.service':
      ensure => present,
      mode   => '0644',
      owner  => root,
      group  => root,
      source => "puppet:///modules/${module_name}/common/systemd/create-nvidia-mdev.service",
      notify => Exec['daemon reload for nvidia_mdev']
    }

    exec { 'daemon reload for nvidia_mdev':
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }

    service { 'create-nvidia-mdev.service':
      ensure => stopped,
      enable => true
    }
  }
}
