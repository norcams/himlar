#
class profile::logging::logstash() {

  include ::logstash

  ::logstash::configfile { 'openstack':
    content => template("${module_name}/logging/logstash/openstack.conf.erb")
  }

  file { '/etc/logstash/patterns/patterns':
    content => template("${module_name}/logging/logstash/patterns.erb")
  }
}
