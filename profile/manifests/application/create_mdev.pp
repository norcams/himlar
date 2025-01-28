# Profile class for creating mdev devices on vGPU nodes
#
# Ensures that:
#   - The rpm package "nrec-vgpu-mdev" is installed
#   - The service "create-mdev" is enabled
#   - The sercice "create-mdev" is configured (/etc/sysconfig/create-mdev)
#
# Author: trondham
# Date:   2022-12-09
#
class profile::application::create_mdev(
  $enable = false,
  $nvidia_gpu_type,
  $trait
) {
  if $enable {

    package { 'nrec-vgpu-mdev':
      ensure => installed,
    }

    service { 'create-mdev.service':
      enable => true,
    }

    file { '/etc/sysconfig/create-mdev':
      ensure => present,
    }->
    file_line { 'Set value for NVIDIA GPU type':
      path  => '/etc/sysconfig/create-mdev',  
      line  => "NVIDIA_GPU_TYPE='$nvidia_gpu_type'",
      match => "^NVIDIA_GPU_TYPE=.*$",
    }->
    file_line { 'Set value for trait':
      path  => '/etc/sysconfig/create-mdev',  
      line  => "TRAIT=$trait",
      match => "^TRAIT=.*$",
    }
  }
}
