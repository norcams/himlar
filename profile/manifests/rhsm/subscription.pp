class profile::rhsm::subscription (
  $manage = false
) {

  if $manage {
    include ::subscription_manager
  }
}
