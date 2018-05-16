#
class profile::logging::logrotate(
  $manage_logrotate = false,
) {

  if $manage_logrotate {
    include ::logrotate
  }
}
