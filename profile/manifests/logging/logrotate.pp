#
class profile::logging::logrotate(
  $manage_logrotate 		= false,
  $manage_monitor_logrotate = false,

) {

  if $manage_logrotate {
    include ::logrotate
  }

  if $manage_monitor_logrotate {
    tidy { 'carbon-cache':
      path  =>  '/opt/graphite/storage/log/carbon-cache/carbon-cache-a/',
      age => '24w',
      recurse => true,
      matches => '.*log.*',
    }
  }

}
