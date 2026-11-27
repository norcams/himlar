# Manages apt with https://github.com/puppetlabs/puppetlabs-apt
class profile::base::apt(
  $manage_sources = false,
  String $merge_strategy = 'deep'
) {
  if $manage_sources {
    $apt_keyrings = lookup('profile::base::apt::apt_keyrings', Optional[Hash], $merge_strategy, undef)
    $apt_sources  = lookup('profile::base::apt::apt_sources', Optional[Hash], $merge_strategy, undef)
    $apt_pins     = lookup('profile::base::apt::apt_pin', Optional[Hash], $merge_strategy, undef)

    if $apt_keyrings != undef {
      create_resources(apt::keyring, $apt_keyrings)
    }

    if $apt_sources != undef {
      create_resources(apt::source, $apt_sources)
    }

    if $apt_pins != undef {
      create_resources(apt::pin, $apt_pins)
    }
  }
}
