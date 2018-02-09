# Manages repo with https://github.com/openstack/puppet-openstack_extras
# This class is part of profile::base::common
class profile::base::yumrepo() {
  # We use deep merge of repo_hash
  $repo_hash = lookup('profile::base::yumrepo::repo_hash', Hash, 'deep', {})

  # Openstack_extras uses yumrepo resource from core puppet for repo_hash syntax:
  # https://docs.puppet.com/puppet/3.8/reference/types/yumrepo.html
  class { '::openstack_extras::repo::redhat::redhat':
    repo_hash => $repo_hash
  }

}
