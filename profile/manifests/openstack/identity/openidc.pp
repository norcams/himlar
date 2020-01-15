# == class: keystone::federation::openidc [70/1473]
#
# == Parameters
#
# [*methods*]
#  A list of methods used for authentication separated by comma or an array.
#  The allowed values are: 'external', 'password', 'token', 'oauth1', 'saml2'
#  (Required) (string or array value).
#  Note: The external value should be dropped to avoid problems.
#
# [*idp_name*]
#  The name name associated with the IdP in Keystone.
#  (Required) String value.
#
# [*openidc_provider_metadata_url*]
#  The url that points to your OpenID Connect metadata provider
#  (Required) String value.
#
# [*openidc_client_id*]
#  The client ID to use when handshaking with your OpenID Connect provider
#  (Required) String value.
#
# [*openidc_client_secret*]
#  The client secret to use when handshaking with your OpenID Connect provider
#  (Required) String value.
#
# [*openidc_crypto_passphrase*]
#  Secret passphrase to use when encrypting data for OpenID Connect handshake
#  (Optional) String value.
#  Defaults to 'openstack'
#
# [*openidc_response_type*]
#  Response type to be expected from the OpenID Connect provider.
#  (Optional) String value.
#  Defaults to 'id_token'
#
# [*keystone_endpoint*]
#  The base public endpoint URL for keystone
#
# [*template_order*]
#  This number indicates the order for the concat::fragment that will apply
#  the shibboleth configuration to Keystone VirtualHost. The value should
#  The value should be greater than 330 an less then 999, according to:
#  https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/vhost.pp
#  The value 330 corresponds to the order for concat::fragment  "${name}-filters"
#  and "${name}-limits".
#  The value 999 corresponds to the order for concat::fragment "${name}-file_footer".
#  (Optional) Defaults to 331.
#
# [*package_ensure*]
#   (optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*openidc_package_name*]
#  Package name for the apache httpd module
#
class profile::openstack::identity::openidc (
  $methods,
  $idp_name,
  $openidc_provider_metadata_url,
  $openidc_client_id,
  $openidc_client_secret,
  $openidc_crypto_passphrase   = 'openstack',
  $openidc_response_type       = 'id_token',
  $keystone_endpoint           = 'http://localhost:5000/',
  $template_order              = 331,
  $package_ensure              = present,
  $openidc_package_name        = 'mod_auth_openidc'
) {

  include ::apache

  # Note: if puppet-apache modify these values, this needs to be updated
  if $template_order <= 330 or $template_order >= 999 {
    fail('The template order should be greater than 330 and less than 999.')
  }

  if ('external' in $methods ) {
    fail('The external method should be dropped to avoid any interference with mapped.')
  }

  if !('openid' in $methods ) {
    fail('Methods should contain openid as one of the auth methods.')
  }

  keystone_config {
    'auth/methods': value  => join(any2array($methods),',');
    'auth/openidc': ensure => absent;
  }

  ensure_packages([$openidc_package_name], {
    ensure => $package_ensure,
    tag    => 'keystone-support-package',
  })

  concat::fragment { 'configure_openidc_keystone':
    target  => "${keystone::wsgi::apache::priority}-keystone_wsgi.conf",
    content => template("${module_name}/openstack/keystone/openidc.conf.erb"),
    order   => $template_order,
  }

}
