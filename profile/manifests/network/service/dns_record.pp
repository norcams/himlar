#
define profile::network::service::dns_record(
  $type,
  $options,
  $records,
) {
  validate_hash($options)
  validate_hash($records)

  case $type {
    'CNAME': {
      $record_name = $name
      $data = regsubst($records[$name],'(.*[^.])$','\1.')
    }
    'PTR': {
      $record_name = $name
      $data = regsubst($records[$name],'(.*[^.])$','\1.')
    }
    default: {
      $record_name = $name
      $data   = $records[$name]
    }
  }

  if is_hash($options[$name]) {
    $record_options = merge($options['default'], $options[$name])
  } else {
    $record_options = $options['default']
  }

  $record = {
    "${type}_record_${name}" => {
      'record' => $record_name,
      'type'   => $type,
      'data'   => $data,
    },
  }
  create_resources('resource_record', $record, $record_options)
}

