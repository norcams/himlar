#
# class profile::virtualization::nested
#
# Turn on nested virtualization in kernel module when using kvm:
# http://docs.openstack.org/developer/devstack/guides/devstack-with-nested-kvm.html
#
class profile::virtualization::nested(
  $manage = false,
  $module = 'kvm-intel',
  $option = 'nested',
  $value = 'y'
) {

  if $manage {
    include ::kmod
    kmod::load { $module: }

    kmod::option { 'Turn on nested virtualization':
      module => $module,
      option => $option,
      value  =>  $value
    }
  }
}
