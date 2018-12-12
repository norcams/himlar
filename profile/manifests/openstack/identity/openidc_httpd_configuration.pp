# == define: keystone::federation::openidc_httpd_configuration  [70/1473]
#
# == Parameters
#
# [*port*]
#  The port number to configure OpenIDC federated authentication on
#  (Required) String value.
#
# [*keystone_endpoint*]
#  The keystone endpoint to use when configuring the OpenIDC redirect back
#  to keystone
#  (Required) String value.
#
define profile::openstack::identity::openidc_httpd_configuration (
  $keystone_endpoint = undef
) {
  concat::fragment { "configure_openidc_on_port_${name}":
    target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_${title}.conf",
    content => template("${module_name}/openstack/keystone/openidc.conf.erb"),
    order   => $profile::openstack::identity::openidc::template_order,
  }
}
