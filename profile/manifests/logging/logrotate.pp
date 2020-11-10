#
class profile::logging::logrotate(
  $manage_logrotate 		= false,
  $manage_monitor_logrotate = false,
  $path     = '',
  $age      = '12w',
  $recurse  = true,
  $matches  = '.*log.*',
) {

  if $manage_logrotate {
    include ::logrotate
  }

  if $manage_monitor_logrotate {
    tidy { 'carbon-cache':
      path      => $path,
      age       => $age,
      recurse   => $recurse,
      matches   => $matches,
    }
  }
}
