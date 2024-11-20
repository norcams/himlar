#!/bin/bash

#
# This script syncronizes the 'secrets' repository on the login nodes
# using the 'Controlmaster' functionality of SSH to avoid multiple 2FA
# authentication requests.
#
# It can be run on any login node, but the behaviour is decided upon
# which host it is run on:
#
# - if master then sync with slaves (one at a time, selectable which ones)
# - if slave then sync with master only
#
# Files with the same name (and location) on several nodes, but otherwise
# dissimilar, will have their newest version synced. If 'ctime' is exactly
# the same, then the version on master survives.
#
# Running with 'del' as an extra option will remove files from slaves which
# does not exist on master.
#
# The directory structure must be the same on both ends. Group owner on all
# files and directories must be 'wheel', and group writable.
#
# Before sync all db dump files (other than longterm archives) older than AGELIMIT days are purged
#

# The script MUST be run as a non-root user
if [ $UID -eq 0 ]; then
    echo
    echo 'ERROR:'
    echo '  This script must be run as yourself, NOT as root!'
    echo
    exit 1
fi

MASTER=osl-login-01.iaas.uio.no
SLAVES="osl-login-02.iaas.uio.no bgo-login-01.iaas.uib.no bgo-login-02.iaas.uib.no"

BASE="/opt/repo"
DBDUMPDIR="${BASE}/secrets/dumps"
FILES="${BASE}/secrets/common ${BASE}/secrets/nodes ${DBDUMPDIR} ${BASE}/public"
AGELIMIT=10                                                                              # limit no. days for dump deletion

# Array of data areas listed in $FILES which should be ignored differently on each servers
# Comma-separated list of areas; each must be equal to an entry in $FILES
declare -A IGNORELIST
IGNORELIST[osl-login-01]=[$DBDUMPDIR]
IGNORELIST[osl-login-02]=[$DBDUMPDIR]
IGNORELIST[bgo-login-01]=[$DBDUMPDIR]
IGNORELIST[bgo-login-02]=[$DBDUMPDIR]

# Some pseudo random file name as the control socket
controlfile="~/.${0##*/}-$$"

# Not allowed to sync mod time if older on master, so skip 't' for now.
# (and thus has to avoid the use of '-a')
rsync_ssh="-e ssh -S $controlfile"
#RSYNC_OPTS="-rlpgoDztO"; # $rsync_ssh"
RSYNC_OPTS="-auvzO"; # $rsync_ssh"
SSH_OPTS="-Nf -o ControlPersist=20 -S $controlfile"

# Temp: problems quoting the '-e' option correctly -> the rsync command has
# this part of the argument list copied "all over the place" for now.

# For now just a simple argument check
if [ "$1"x = "delx" ]; then
    update="true"
    RSYNC_OPTS="$RSYNC_OPTS --delete"
else
    update=""
fi


host=$(hostname)
location=${host:0:3}                                                                     # based on the convention: hostname start with three letter location code
myself=$(readlink -f $0)

# make sure we always stop our control master
function finish  {
    if [ $host = "$MASTER" ]; then
        ssh $SLAVE -S $controlfile -O exit
    else
        ssh $MASTER -S $controlfile -O exit
    fi
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
        # only work on directories named something resembling a db node backup directory
        # this is really crude but bash is somewhat lacking in this respect and we want
        # avoid complexity if not necessary
        for dumpdir in ${dbdumpdirs}/[a-z]*-db-*/; do
            if [[ -d "${dumpdir}" && ! -L "${dumpdir}" ]]; then                          # only consider (real!) directories
                find "${dumpdir}/" -ignore_readdir_race -maxdepth 1 -name "*.sql*" -type f -mtime +$expiration_days -print0 | xargs -0 -r rm -f
#                find "${dumpdir}/" -ignore_readdir_race -maxdepth 1 -name "*.sql*" -type f -mtime +$expiration_days -print0 | xargs -0 -r echo
            fi
        done
    else
        echo "Ignoring invalid expiration date ($expiration_days), not cleaning up\!"
    fi
}


echo "NB:"
echo "  Our rsync are missing the '-J' option, ignore errors regarding time stamps on symlinks"
echo

#
# perform the actual syncronization job
#

# This is now taken care of in the db-sync script
## ... after first purged old dumps locally
#cleanup ${AGELIMIT} ${DBDUMPDIR}

if [ $location = "osl" ]; then

    # We are the MASTER -> sync to slaves

    # do them one at a time, requesting confirmation for each
    for SLAVE in $SLAVES; do

        read -p "Do you want to sync with $SLAVE? (y/N)" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then

            ssh -M $SSH_OPTS $SLAVE                                                      # set up control master

# This is now taken care of in the db-sync script
#            # purge old db dump files
#            ssh -S $controlfile ${SLAVE} "$(declare -f cleanup); cleanup ${AGELIMIT} ${DBDUMPDIR}"

            # sync files from us
            for dirfile in $FILES $myself; do
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
        fi
    done
else
    # We are but a simple slave -> get data from our MASTER
    ourname=$(hostname -s)

    ssh -M $SSH_OPTS $MASTER                                                             # set up control master

# This is now taken care of in the db-sync script
#    # purge old db dump files
#    ssh -S $controlfile ${MASTER} "$(declare -f cleanup); cleanup ${AGELIMIT} ${DBDUMPDIR}"

    # sync files
    for dirfile in $FILES; do
        if [[ ! ${IGNORELIST[${ourname}]} =~ $dirfile ]]; then
            if [ -d $dirfile ]; then dirfile="${dirfile}/"; fi
            # ... from master
#            echo "KJØRER: rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" ${MASTER}:$dirfile $dirfile"
            rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" ${MASTER}:$dirfile $dirfile
            # ... then upload files which only exists here
#            echo "KJØRER: rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" $dirfile ${MASTER}:$dirfile"
            rsync ${RSYNC_OPTS} -e "ssh -S $controlfile" $dirfile ${MASTER}:$dirfile
        fi
    done
fi

