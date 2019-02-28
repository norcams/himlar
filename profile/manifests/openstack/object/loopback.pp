#
# Helper class to create loopback disk for testing. Uses swift module
#
class profile::openstack::object::loopback(
  $disks = {}
) {

  # Use loopback for testing in vagrant and disk otherwise
  create_resources('profile::storage::loopback', $disks)

}
