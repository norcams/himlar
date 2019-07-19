#
class profile::logging::logstash(
  $config_files = {}
) {

  include ::logstash

  # This is the config files in /etc/logstash/conf.d/
  create_resources('logstash::configfile', $config_files)

  file { '/etc/logstash/patterns/patterns':
    content => template("${module_name}/logging/logstash/patterns.erb")
  }
}
