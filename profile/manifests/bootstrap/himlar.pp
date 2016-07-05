#
class profile::bootstrap::himlar(
  $manage_bootstrap_scripts = false,
) {

  if $manage_bootstrap_scripts {
    include himlar_bootstrap
    include himlar_bootstrap::instances
  }

}
