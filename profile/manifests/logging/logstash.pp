#
class profile::logging::logstash() {

  include ::logstash

  file { '/etc/logstash/patterns/extra':
    ensure => present,
    content => template("${module_name}/logging/logstash/patterns.erb")
  } ->
  file { '/etc/logstash/elasticsearch-template.json':
    ensure => present,
    content => template("${module_name}/logging/logstash/elasticsearch-template.json")
  }
  ::logstash::configfile { 'openstack':
    content => template("${module_name}/logging/logstash/openstack.conf.erb")
  }
}
