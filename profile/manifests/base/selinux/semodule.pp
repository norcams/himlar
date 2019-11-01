#
# This class compiles and loads SELinux modules based on avc denial messages
#
define profile::base::selinux::semodule(
  $avc_msg        = undef,
  $avc_file       = undef,
  $workdir        = '/usr/share/selinux/local',
  $semodule_name  = undef,
) {

  if $avc_msg or $avc_file {

    if $avc_msg and $avc_file {
        fail('Only one of avc_msg or avc_file must be set.')
    }

    ensure_resource('file', $workdir, { 'ensure' => 'directory' })

    $_title   = regsubst(downcase($title), '[\s-]','_','G')
    $avcfile  = "${workdir}/avc_${avc_file}.txt"
    $semodule = pick($semodule_name, "local_fix_${avc_file}")

    file { $avcfile:
      ensure  => file,
      content => $avc_msg,
      source  => "puppet:///modules/${module_name}/base/${avc_file}",
      require => File[$workdir],
      notify  => Exec["build-policy-module-${semodule}"],
    }

    exec { "build-policy-module-${semodule}":
      command     => "audit2allow -i ${avcfile} -M ${semodule}",
      cwd         => $workdir,
      path        => ['/usr/bin'],
      refreshonly => true,
      notify      => Exec["install-policy-module-${semodule}"],
    }

    exec { "install-policy-module-${semodule}":
      command     => "semodule -i ${workdir}/${semodule}.pp",
      path        => '/usr/sbin',
      refreshonly => true,
    }
  }
}
