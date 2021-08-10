#
class profile::database::redis (
  $manage = true
) {

  if $manage {
    include ::redis
  }

}
