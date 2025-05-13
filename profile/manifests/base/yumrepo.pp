# Manages repo with https://github.com/openstack/puppet-openstack_extras
# or the new yumrepo_core depending on el version
# This class is part of profile::base::common
class profile::base::yumrepo(
  $merge_strategy  = 'deep',
  $purge_unmanaged = false
) {

  $repo_hash = lookup('profile::base::yumrepo::repo_hash', Hash, $merge_strategy, {})
  case $::operatingsystemmajrelease {
    '7': {
      # Openstack_extras uses yumrepo resource from core puppet for repo_hash syntax:
      # https://docs.puppet.com/puppet/3.8/reference/types/yumrepo.html
      class { '::openstack_extras::repo::redhat::redhat':
        repo_hash => $repo_hash
      }
    }
    # From puppet 6 we use the new yumrepo_core from puppetlabs
    '8', '9': {
      create_resources('yumrepo', $repo_hash)
      if $purge_unmanaged {
        resources { 'yumrepo':
          purge => true
        }
      }
    }
    default: {
    }
  }
}
