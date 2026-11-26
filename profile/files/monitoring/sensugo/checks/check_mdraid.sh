#!/bin/bash
#
# Managed by Puppet (profile::monitoring::mdraid) - do not edit on the node.
#
# Sensu check for Linux software RAID health. Everything it needs is in
# /proc/mdstat, which is world readable, so no root and no sudo rule.
#
# Exit codes: 0 ok, 1 warning, 2 critical, 3 unknown.
#
# An array that is degraded and rebuilding is a warning, it is fixing itself.
# Degraded and not rebuilding is critical, nothing is going to happen without
# us. A scrub or resync on an otherwise healthy array is fine and only shows
# up in the output.

set -u

MDSTAT="${1:-/proc/mdstat}"

if [ ! -r "${MDSTAT}" ]; then
  echo "UNKNOWN: cannot read ${MDSTAT}"
  exit 3
fi

awk '
/^md[0-9A-Za-z_]+[[:space:]]*:/ {
    cur = $1
    n++
    arrays[n]     = cur
    inactive[cur] = ($3 == "inactive")
    failed[cur]   = (index($0, "(F)") > 0)
    next
}

# The block count line, ends in the per device status: [2/1] [U_]
cur != "" && match($0, /\[[U_]+\]/) {
    status[cur] = substr($0, RSTART + 1, RLENGTH - 2)
    next
}

# The progress line: [==>..........]  recovery = 22.5% (...) finish=...
cur != "" && match($0, /(recovery|resync|reshape|check|repair)[[:space:]]*=/) {
    action[cur] = substr($0, RSTART, RLENGTH - 1)
    sub(/[[:space:]]+$/, "", action[cur])
    if (match($0, /[0-9.]+%/)) {
        pct[cur] = substr($0, RSTART, RLENGTH)
    }
    next
}

/^unused devices:/ { cur = "" }

END {
    if (n == 0) {
        print "OK: no md arrays on this host"
        exit 0
    }

    ncrit = 0
    nwarn = 0

    for (i = 1; i <= n; i++) {
        dev  = arrays[i]
        st   = (dev in status) ? status[dev] : ""
        act  = (dev in action) ? action[dev] : ""
        prog = (dev in pct)    ? " " pct[dev] : ""
        down = (index(st, "_") > 0)

        if (inactive[dev]) {
            crit[++ncrit] = dev " inactive"
        } else if (down && act != "") {
            warn[++nwarn] = dev " degraded [" st "], " act prog
        } else if (down) {
            crit[++ncrit] = dev " degraded [" st "], no rebuild running"
        } else if (failed[dev]) {
            warn[++nwarn] = dev " has a failed device [" st "]"
        } else if (act != "") {
            ok_msg[i] = dev " " act prog
        } else if (st != "") {
            ok_msg[i] = dev " [" st "]"
        } else {
            # raid0 and linear have no per device status line
            ok_msg[i] = dev " active"
        }
    }

    if (ncrit > 0) {
        line = "CRITICAL:"
        for (i = 1; i <= ncrit; i++) { line = line " " crit[i] ";" }
        for (i = 1; i <= nwarn; i++) { line = line " " warn[i] ";" }
        print line
        exit 2
    }

    if (nwarn > 0) {
        line = "WARNING:"
        for (i = 1; i <= nwarn; i++) { line = line " " warn[i] ";" }
        print line
        exit 1
    }

    line = "OK: " n " array(s) healthy -"
    for (i = 1; i <= n; i++) {
        if (i in ok_msg) { line = line " " ok_msg[i] ";" }
    }
    print line
    exit 0
}
' "${MDSTAT}"
