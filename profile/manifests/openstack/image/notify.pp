#
class profile::openstack::image::notify() {

  include ::glance::notify::rabbitmq

}
