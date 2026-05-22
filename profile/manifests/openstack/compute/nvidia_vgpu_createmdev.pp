#
# For NVIDIA vGPU cards utilizing SR-IOV, the SR-IOV VFs are not enabled
# automatically at boot. This service runs sriov-manage before the separate
# create-mdev service creates mediated devices.
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
