#
class profile::application::git(
  $enable = true
) {
  $settings = lookup('profile::application::git::settings', Hash, 'deep', {})

  if $enable {
    class { "::gitolite":
      settings => $settings
    }
  }

}
