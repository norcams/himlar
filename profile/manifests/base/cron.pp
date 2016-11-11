#
class profile::base::cron(
  $crontabs = {}
) {
  create_resources('cron', $crontabs)
}
