# Class: profile::storage::mapbd
#
#
class profile::storage::maprbd (
  $manage_maprbd = false,
  $rbd_images    = {},
) {

  include ::ceph::profile::client

  if $manage_maprbd {
    # Pass a hash with pool/imagename and parameters
    unless empty($rbd_images) {
      file { "/etc/ceph/rbdmap.service":
        ensure  => file,
        path    => "/etc/ceph/rbdmap.service",
        content => template("${module_name}/storage/maprbd_service.erb"),
      } ~>
      service { "Map rbd images":
        enable      => true,
        hasrestart  => false,
        name        => "rbdmap",
      }
    }
  }
}
