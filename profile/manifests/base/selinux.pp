#
class profile::base::selinux(
  $manage_selinux = false,
  $ports = {}
) {

  if $manage_selinux {
    warning('NORCAMS: selinux are enforcing!!!')
    include ::selinux

    create_resources('selinux::port', $ports)

  }

}
