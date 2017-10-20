#
# This class enables selinux, add packages and rules for selinux
# 
class profile::base::selinux(
  $manage_selinux = false,
  $packages = ['setroubleshoot-server', 'setools-console']
) {

  if $manage_selinux {
    warning('NORCAMS: selinux now are enforcing!')
    include ::selinux

    $ports = hiera_hash('profile::base::selinux::ports', {})
    $boolean = hiera_hash('profile::base::selinux::boolean', {})

    create_resources('selinux::port', $ports)
    create_resources('selinux::boolean', $boolean)

    package { $packages:
      ensure => installed
    }

  }

}
