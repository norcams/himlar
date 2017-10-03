# Class: profile::storage::cephmon
#
#
class profile::storage::cephmon {
  include ::ceph::profile::mon
  include ::ceph::profile::mgr
}
