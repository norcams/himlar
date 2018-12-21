#
# Create extra configuration for ceph
#
define profile::storage::ceph_extraconf (
  $manage                = true,
  $config_section        = "client",
  $config_key            = "default",
  $config_value          = "default",
) {

  if $manage {
    ceph_config {
      "$config_key": value => $config_value;
    }
  }
}
