# Class: profile::storage::cephclient
#
#
class profile::storage::cephclient(
  Boolean $enable = false,
  Boolean $create_extraconf = false,
) {

  if $enable {
    include ::ceph::profile::client

    if $create_extraconf {
      create_resources(profile::storage::ceph_extraconf, lookup('profile::storage::ceph_extraconf::config', Hash, 'deep'))
    }
  }
}
