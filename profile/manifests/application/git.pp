#
class profile::application::git(
  $enable = true
) {
  $settings = hiera_hash('profile::application::git::settings')

  if $enable {
    class { ::gitolite:
      settings => $settings
    }
  }

}
