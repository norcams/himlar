class profile::openstack::orchestration::api (
  $api_cfn_enabled        = true,
  $api_cloudwatch_enabled = true,
) {

  include profile::openstack::orchestration

  include ::heat::api

  if $api_cfn_enabled {
    include ::heat::api_cfn
  }

  if $api_cloudwatch_enabled {
    include ::heat::api_cloudwatch
  }

}
