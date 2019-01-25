#
# Simple class to install mod_status and setup a vhost on localhost
# This will create all you need to use sensu-plugins-apache metric
#
class profile::webserver::apache::status(
  $manage_status = false
) {

  if $manage_status {

    include ::apache::mod::status
    include ::profile::webserver::apache

    $vhost = {
      'status' => {
        'ip'             => '127.0.0.1',
        'port'           => 80,
        'manage_docroot' => false,
        'docroot'        => '/var/www/html'
      }
    }

    create_resources('::apache::vhost', $vhost)

  }
}
