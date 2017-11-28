#
define profile::network::service::dns_record_type(
  $options,
  $records,
) {

  $type_options          = $options[$name]
  $type_records          = $records[$name]
  $type_record_resources = join_keys_to_values($records[$name], '_')

  profile::network::service::dns_record { $type_record_resources:
    type    => $name,
    options => $type_options,
    records => $type_records,
  }

}

