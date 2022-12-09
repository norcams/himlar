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
  $enable = false
) {
  if $enable {

    $nvidia_gpu_type       = $::profile::application::create_mdev::nvidia_gpu_type
    $max_instances_per_gpu = $::profile::application::create_mdev::max_instances_per_gpu
    
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
    file_line { 'Set value for max number of instances per GPU':
      path  => '/etc/sysconfig/create-mdev',  
      line  => "MAX_INSTANCES_PER_GPU=$max_instances_per_gpu",
      match => "^MAX_INSTANCES_PER_GPU=.*$",
    }
  }
}
