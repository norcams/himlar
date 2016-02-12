#
#
class profile::base::passwords  (
    $passwords = undef,
)
{

  $passwords = hiera('profile::base::passwords', {})

  if $passwords['root']  {
    user  { root:
      password => $passwords['root'],
    }
  }
}
