#
class profile::logging::elk(
  $manage_elk            = false,
  $manage_elasticksearch = false,
  $manage_logstash       = false,
  $manage_kibana         = false,
) {

  if $manage_elk  {

    if $manage_elasticksearch  {
      include profile::logging::elasticsearch
    }

    if $manage_logstash  {
      include profile::logging::logstash
    }

    if $manage_kibana  {
      include profile::logging::kibana
    }
  }
}
