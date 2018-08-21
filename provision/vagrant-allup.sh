#!/bin/bash

# Before you run the script:
# yum install 'perl(Readonly)' 'perl(YAML::XS)'
# generate CA passfile

# Help text
if [ "$1" == '-h' -o "$1" == '--help' ]; then
    cat <<'EOF'
Helper script to bring up all vagrant nodes, in the order that they
are defined in nodes.yaml

Usage:
  vagrant-allup.sh

Environment variables:
  HIMLAR_MAX_LOGS : maximum number of logs to keep (per node)

Logs will be available in
  /tmp/himlar-<username>

EOF
    exit 0
fi

# Test if perl requirements are met
for module in Readonly YAML::XS; do
    if ! perl -e "use $module;" 2>/dev/null; then
	echo "ERROR: Missing perl module $module. Suggested fix:"
	echo "  sudo yum install 'perl($module)'"
	exit 1
    fi
done

# Get nodes from nodes.yaml
nodes=$(./provision/get_vagrant_nodes.pl)

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

# Bring up nodes in order
for node in $nodes; do
    rotate_logs $node
    vagrant up $node | tee $logdir/$node-$today
    rotate_logs $node
    vagrant provision $node | tee $logdir/$node-$today
    rotate_logs $node
    vagrant provision $node | tee $logdir/$node-$today
done

# Run puppet an extra time on each node
for node in $nodes; do
    vagrant provision $node | tee $logdir/$node-$today
    rotate_logs $node
done
