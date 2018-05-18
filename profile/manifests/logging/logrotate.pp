#
class profile::logging::logrotate(
  $manage_logrotate = false,
) {

  if $manage_logrotate {
    include ::logrotate
    file { '/etc/logrotate.conf':
        ensure  => 'present',
        replace => 'no', # this is the important property
        mode    => '0644',
    }
  }
}
