# manage /etc/ceilometer/pipeline.yaml
class profile::openstack::telemetry::pipeline (
  $pipeline_publishers      = []
) {

  unless empty($pipeline_publishers) {
    file { '/etc/ceilometer/pipeline.yaml':
      ensure                  => present,
      content                 => template("${module_name}/openstack/telemetry/pipeline.yaml.erb"),
      selinux_ignore_defaults => true,
      mode                    => '0640',
      owner                   => 'root',
      group                   => 'ceilometer',
    }
  }

}
