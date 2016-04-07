#
class profile::logging::logstash() {

  include ::logstash

  file { '/etc/logstash/patterns/extra':
    ensure => present,
    content => template("${module_name}/logging/logstash/patterns.erb")
  } ->
  ::logstash::configfile { 'openstack':
    content => template("${module_name}/logging/logstash/openstack.conf.erb")
  }
}
