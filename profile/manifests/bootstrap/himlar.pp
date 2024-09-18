#
class profile::bootstrap::himlar(
  $manage_bootstrap_scripts = false,
) {

  if $manage_bootstrap_scripts {
    include ::bootstrap_infra

    $tftp = lookup('profile::bootstrap::himlar::tftp', Hash, 'deep', {})
    $libvirt = lookup('profile::bootstrap::himlar::libvirt', Hash, 'deep', {})

    create_resources('::bootstrap_infra::install::tftp', $tftp)
    create_resources('::bootstrap_infra::install::libvirt', $libvirt)

  }

}
