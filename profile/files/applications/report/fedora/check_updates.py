dnf_failure = False
base = dnf.Base()
base.conf.substitutions.update_from_etc("/")

try:
    base.read_all_repos()
    base.fill_sack()
    upgrades = base.sack.query().upgrades().run()

except:
    dnf_failure = True

if dnf_failure:
    pkg_output = -1
else:
    pkg_output = len(upgrades)

