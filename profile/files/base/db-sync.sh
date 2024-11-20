#!/bin/bash

#
# Script to syncronize database backup dumps between login nodes.
#
# Script requires an argument pointing to the login node to sync against.
# It is suitable to set this up as a cron job to sync between regions. I.e. on one of
# the regions login-01 nodes, configure a job to sync against the compatriot node.
# If so required, the script may be run manually to sync data at other times, or against
# one of the other login nodes.
#
# Data is synced both ways; newest file wins.
#
# Except for the regular pruning of old data, the script does not delete files not existing
# in the other site. It just adds or updates files. With the '--delete' option files not
# existing at the local end is deleted from the remote. Use with care!
#
# The script may be run from any login node, as long as there is access.
#

# The script MUST be run as a non-root user
if [ $UID -eq 0 ]; then
    echo
    echo 'ERROR:'
    echo '  This script must be run as yourself, NOT as root!'
    echo
    exit 1
fi


BASE="/opt/repo"
DBDUMPDIR="${BASE}/secrets/dumps"
AGELIMIT=10                                                                              # limit no. days for dump deletion

# Array of data areas listed in $FILES which should be ignored differently on each servers
# Comma-separated list of areas; each must be equal to an entry in $FILES
declare -A IGNORELIST
IGNORELIST[osl-login-01]=[]
IGNORELIST[osl-login-02]=[]
IGNORELIST[bgo-login-01]=[]
IGNORELIST[bgo-login-02]=[]

# Some pseudo random file name as the control socket
controlfile="~/.${0##*/}-$$"

# Not allowed to sync mod time if older on master, so skip 't' for now.
# (and thus has to avoid the use of '-a')
rsync_ssh="-e ssh -S $controlfile"
#RSYNC_OPTS="-rlpgoDztOJ"; # $rsync_ssh"
RSYNC_OPTS="-auvzOJ"; # $rsync_ssh"
SSH_OPTS="-Nf -o ControlPersist=20 -S $controlfile"

# Temp: problems quoting the '-e' option correctly -> the rsync command has
# this part of the argument list copied "all over the place" for now.

# For now just a small and stupid argument check
if [ "$1"x = "--deletex" ]; then
    update="true"
    RSYNC_OPTS="$RSYNC_OPTS --delete"
    SLAVE="$2"
else
    update=""
    SLAVE="$1"
fi
if [ ${SLAVE}x = "x" ]; then
    echo "No client specified? Mandatory!"
    exit 1
fi


host=$(hostname)
location=${host:0:3}                                                                     # based on the convention: hostname start with three letter location code
myself=$(readlink -f $0)

# make sure we always stop our control master
function finish  {
    ssh $SLAVE -S $controlfile -O exit
}
trap finish EXIT


# routine for deleting old backups
cleanup()
{
    local expiration_days=$1
    local dbdumpdirs=$2

    # some kind of protection against working in the wrong areas
    if ! [[ "$dbdumpdirs" =~ /opt/.*/ ]]; then
        echo "Illegal db dump directory argument (must start with 'opt')"
        return
    fi

    if [ $expiration_days -gt 0 ]; then
        # only work on directories named something resembling one of our knwn db node backup directories
        # this is really crude but bash is somewhat lacking in this respect and we want
        # to avoid complexity if not necessary
        for dumpdir in ${dbdumpdirs}/[a-z]*-db-*/ ${dbdumpdirs}/[a-z]*-metric-*/ ; do
            if [[ -d "${dumpdir}" && ! -L "${dumpdir}" ]]; then                          # only consider (real!) directories
#                find "${dumpdir}/" -ignore_readdir_race -maxdepth 1 -name "*.sql*" -type f -mtime +$expiration_days -print0 | xargs -0 -r rm -f
                find "${dumpdir}/" -ignore_readdir_race -maxdepth 1 -name "*.sql*" -type f -mtime +$expiration_days -print0 | xargs -0 -r echo
            fi
        done
    else
        echo "Ignoring invalid expiration date ($expiration_days), not cleaning up\!"
    fi
}


# Set up control master so we can run several commands against client with just one authentication request
echo
ssh -M $SSH_OPTS $SLAVE

#
# perform the actual syncronization job
#

# ... after first purged old dumps locally
cleanup ${AGELIMIT} ${DBDUMPDIR}
# ... and remotely
ssh -S $controlfile ${SLAVE} "$(declare -f cleanup); cleanup ${AGELIMIT} ${DBDUMPDIR}"

# sync files
for dirfile in ${DBDUMPDIR} ; do
    if [[ ! ${IGNORELIST[${SLAVE%%\.*}]} =~ $dirfile ]]; then
        if [ -d $dirfile ]; then dirfile="${dirfile}/"; fi
#                    echo "KJØRER: rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" $dirfile ${SLAVE}:$dirfile"
        # ... from us
        rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" $dirfile ${SLAVE}:$dirfile
        # ... and then get files on slave if 'del' option not set
        if [ -z $update ]; then
#                        echo "KJØRER: rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" ${SLAVE}:$dirfile $dirfile"
            rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" ${SLAVE}:$dirfile $dirfile
        fi
    fi
done

