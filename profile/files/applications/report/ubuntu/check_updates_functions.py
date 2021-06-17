SYNAPTIC_PINFILE = "/var/lib/synaptic/preferences"
DISTRO = subprocess.check_output(["lsb_release", "-c", "-s"],
                                 universal_newlines=True).strip()

def cache_clean(depcache):
    depcache.init()

def save_dist_upgrade(depcache):
    """ this functions mimics a upgrade but will never remove anything """
    depcache.upgrade(True)
    if depcache.del_count > 0:
        cache_clean(depcache)
    depcache.upgrade()

def count_update_packages():
    pkgs = []
    apt_failure = False

    apt_pkg.init()
    # force apt to build its caches in memory for now to make sure
    # that there is no race when the pkgcache file gets re-generated
    apt_pkg.config.set("Dir::Cache::pkgcache", "")

    try:
        cache = apt_pkg.Cache(apt.progress.base.OpProgress())
    except SystemError as error:
        sys.stderr.write("Error: Opening the cache (%s)" % error)
        apt_failure = True

    depcache = apt_pkg.DepCache(cache)
    # read the pin files
    depcache.read_pinfile()
    # read the synaptic pins too
    if os.path.exists(SYNAPTIC_PINFILE):
        depcache.read_pinfile(SYNAPTIC_PINFILE)
    # init the depcache
    depcache.init()

    try:
        save_dist_upgrade(depcache)
    except SystemError as error:
        sys.stderr.write("Error: Marking the upgrade (%s)" % error)
        apt_failure = True

    for pkg in cache.packages:
        if not (depcache.marked_install(pkg) or depcache.marked_upgrade(pkg)):
            continue
        inst_ver = pkg.current_ver
        cand_ver = depcache.get_candidate_ver(pkg)
        if cand_ver == inst_ver:
            continue
        record = {"name": pkg.name,
                  "security": is_security_upgrade(pkg, depcache)}
        pkgs.append(record)

    security_updates = []

    for pkg in pkgs:
        if pkg['security']:
            security_updates.append(pkg)

    if apt_failure:
        output = -1
    else:
        output = len(security_updates)

    return output

def is_security_upgrade(pkg, depcache):

    def is_security_upgrade_helper(ver):
        """ check if the given version is a security update (or masks one) """
        security_pockets = [("Ubuntu", "%s-security" % DISTRO),
                            ("gNewSense", "%s-security" % DISTRO),
                            ("Debian", "%s-updates" % DISTRO)]

        for (f, index) in ver.file_list:
            for origin, archive in security_pockets:
                if f.archive == archive and f.origin == origin:
                    return True
        return False
    inst_ver = pkg.current_ver
    cand_ver = depcache.get_candidate_ver(pkg)

    if is_security_upgrade_helper(cand_ver):
        return True

    # now check for security updates that are masked by a
    # canidate version from another repo (-proposed or -updates)
    for ver in pkg.version_list:
        if (inst_ver and
            apt_pkg.version_compare(ver.ver_str, inst_ver.ver_str) <= 0):
            continue
        if is_security_upgrade_helper(ver):
            return True

    return False

