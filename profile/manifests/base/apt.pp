# Manages apt with https://github.com/puppetlabs/puppetlabs-apt
class profile::base::apt(
  $manage_sources  = false,
  $apt_sources     = {},
  String $merge_strategy  = 'deep'
) {

  if $manage_sources {
    create_resources(apt::keyring, lookup('profile::base::apt::apt_keyrings', Hash, $merge_strategy))
    create_resources(apt::source, lookup('profile::base::apt::apt_sources', Hash, $merge_strategy))
  }
}
