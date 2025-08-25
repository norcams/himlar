#
# This class enables selinux, add packages and rules for selinux
#
class profile::base::selinux(
  $manage_selinux = false,
  $packages = ['setroubleshoot-server', 'setools-console']
) {

  if $manage_selinux {
    info('NORCAMS: SELinux mode is enforcing!')
    include ::selinux

    $ports = lookup('profile::base::selinux::ports', Hash, 'deep', {})
    $boolean = lookup('profile::base::selinux::boolean', Hash, 'deep', {})
    $fcontext = lookup('profile::base::selinux::fcontext', Hash, 'deep', {})
    $exec_restorecon = lookup('profile::base::selinux::exec_restorecon', Hash, 'deep', {})
    $semodules = lookup('profile::base::selinux::semodules', Hash, 'deep', {})

    create_resources('selinux::port', $ports)
    create_resources('selinux::boolean', $boolean)
    create_resources('selinux::fcontext', $fcontext)
    create_resources('selinux::exec_restorecon', $exec_restorecon)
    create_resources('profile::base::selinux::semodule', $semodules)

    package { $packages:
      ensure => installed
    }

  }

}
