# Be quiet!
yumLoggers = ['yum.filelogging.RPMInstallCallback',
              'yum.verbose.Repos',
              'yum.verbose.plugin',
              'yum.Depsolve',
              'yum.verbose',
              'yum.plugin',
              'yum.Repos',
              'yum',
              'yum.verbose.YumBase',
              'yum.filelogging',
              'yum.verbose.YumPlugins',
              'yum.RepoStorage',
              'yum.YumBase',
              'yum.filelogging.YumBase',
              'yum.verbose.Depsolve']

for loggerName in yumLoggers:
    logger = logging.getLogger(loggerName)
    logger.setLevel(__NO_LOGGING)

yum_failure = False
base = yum.YumBase()
try:
    package_list = base.doPackageLists(pkgnarrow='updates',
                                       patterns='',
                                       ignore_case=True)
except:
    yum_failure = True

if yum_failure:
    pkg_output = -1
else:
    pkgs = []

    if package_list.updates:
        for pkg in package_list.updates:
            pkgs.append(pkg)

    pkg_output = len(pkgs)

