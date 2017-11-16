#
define profile::network::service::dns_record(
  $type,
  $options,
  $records,
) {
  validate_hash($options)
  validate_hash($records)

  $record_name = regsubst($name,'_.*$','')

  case $type {
    'CNAME': {
      $data = regsubst($records[$name],'(.*[^.])$','\1.')
    }
    'PTR': {
      $data = regsubst($records[$name],'(.*[^.])$','\1.')
    }
    default: {
      $data   = $records[$name]
    }
  }

  if is_hash($options[$name]) {
    $record_options = merge($options['default'], $options[$name])
  } else {
    $record_options = $options['default']
  }

  $record = {
    "${type}_record_${record_name}" => {
      'record' => $record_name,
      'type'   => $type,
      'data'   => $data,
    },
  }
  create_resources('resource_record', $record, $record_options)
}

