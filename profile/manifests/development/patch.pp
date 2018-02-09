#
class profile::development::patch (
  $role     = $::role,
  $flagfile = '/var/tmp/system-patched',
  $patchdir = '/opt/himlar/provision/patches',
)

{
  exec { 'patch_system':
    command => "/opt/himlar/provision/patches/patch.sh ${role}",
    path    => '/usr/bin:/usr/sbin:/bin',
    cwd     => $patchdir,
    unless  => ["test -f ${flagfile}"],
  }
}
