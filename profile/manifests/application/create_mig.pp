class profile::application::create_mig (
  String[1]                $mig_default_layout = '2g.48gb,2g.48gb,2g.48gb,2g.48gb',
  Hash[Integer, String[1]] $mig_gpu_overrides  = {},
  Boolean                  $enable_sriov       = true,
  String[1]                $package_ensure     = 'installed',  # or pin '1.0.0'
) {

  package { 'nvidia-mig-setup':
    ensure => $package_ensure,
  }

  # Config stays in Puppet/Hiera — NOT in the rpm.
  file { '/etc/nvidia-mig-layout.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('profile/manifests/application/nvidia-mig-layout.conf.epp', {
      'default_layout' => $mig_default_layout,
      'gpu_overrides'  => $mig_gpu_overrides,
      'enable_sriov'   => $enable_sriov,
    }),
    require => Package['nvidia-mig-setup'],
  }

  # The rpm's %post already did daemon-reload + enable, so no unit File
  # resource and no daemon-reload exec here. Just make sure it's enabled.
  service { 'nvidia-mig-setup.service':
    ensure  => running,
    enable  => true,
    require => [Package['nvidia-mig-setup'], File['/etc/nvidia-mig-layout.conf']],
  }
}