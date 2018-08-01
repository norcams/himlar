#!/bin/bash

# Which host are we operating on
if [ -z $1 ]; then
    cat <<'EOF'
Usage:
  vagrant-provision.sh <node>
EOF
    exit 1
else
    host=$1
fi

# Help text
if [ "$host" == '-h' -o "$host" == '--help' ]; then
    cat <<'EOF'
Helper script to run 'vagrant provision' on a single node, while
keeping logs

Usage:
  vagrant-provision.sh <node>

Environment variables:
  HIMLAR_MAX_LOGS : maximum number of logs to keep (per node)

Logs will be available in
  /tmp/himlar-<username>

EOF
    exit 0
fi

# Log directory
logdir=/tmp/himlar-$USER
[ -d $logdir ] || mkdir $logdir

# Date
today=$(date +%Y%m%d)

# Maximum log retention
max_logs=${HIMLAR_MAX_LOGS:-9}

# Function to rotate logs if needed
function rotate_logs() {
    node=$1
    if [ -f $logdir/$node-$today ]; then
	if [ -f $logdir/$node-$today.1 ]; then
	    oldest=$(ls -v $logdir/$node-$today* | tail -n 1 | cut -d. -f2)
	    for i in $(seq $oldest -1 1); do
		mv $logdir/$node-$today.$i $logdir/$node-$today.$(( $i + 1 ))
	    done
	fi
	mv $logdir/$node-$today $logdir/$node-$today.1
    fi
}

# Function to prune logs
function prune_logs() {
    node=$1
    [ -f $logdir/$node-$today.1 ] || return 0
    oldest=$(ls -v $logdir/$node-$today.* | tail -n 1 | cut -d. -f2)
    if [ $oldest -gt $max_logs ]; then
	for i in $(seq $oldest -1 $(( $max_logs + 1 )) ); do
	    rm -f $logdir/$node-$today.$i
	done
    fi
}

rotate_logs $host
vagrant rsync $host | tee $logdir/$host-$today
vagrant provision $host | tee -a $logdir/$host-$today
prune_logs $host

