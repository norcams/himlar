#!/usr/bin/env bash
# Sensu check for MySQL backup marker files.
# Exit codes: 0 = OK, 1 = warning, 2 = critical, 3 = unknown.

set -u
if (( $# > 2 )); then
    echo "UNKNOWN: usage: $0 [DUMP_DIR] [BACKUP_HOSTNAME]"
    exit 3
fi

DUMP_DIR="${1:-${DUMP_DIR:-/var/db/dumps}}"
BACKUP_HOSTNAME="${2:-${BACKUP_HOSTNAME:-$(hostname)}}"

# Defaults suit a roughly daily backup schedule; adjust to your schedule.
WARN_AGE_SECONDS="${WARN_AGE_SECONDS:-7200}"  # 2 hours
CRIT_AGE_SECONDS="${CRIT_AGE_SECONDS:-21600}"  # 6 hours

if [[ ! "$WARN_AGE_SECONDS" =~ ^[0-9]+$ ||
      ! "$CRIT_AGE_SECONDS" =~ ^[0-9]+$ ]] ||
   (( CRIT_AGE_SECONDS <= WARN_AGE_SECONDS )); then
    echo "UNKNOWN: age thresholds must be integers, with critical greater than warning"
    exit 3
fi

now=$(date +%s) || {
    echo "UNKNOWN: could not read current time"
    exit 3
}

status=0
messages=()

set_status() {
    local new_status=$1
    if (( new_status > status )); then
        status=$new_status
    fi
}

check_file() {
    local label=$1
    local file=$2
    local timestamp_source=$3
    local timestamp raw age hours minutes state code

    if [[ ! -f "$file" ]]; then
        messages+=("$label: CRITICAL — file missing: $file")
        set_status 2
        return
    fi

    if [[ ! -r "$file" ]]; then
        messages+=("$label: CRITICAL — file is not readable: $file")
        set_status 2
        return
    fi

    if [[ "$timestamp_source" == "content" ]]; then
        raw=""
        IFS= read -r raw < "$file" || true

        if [[ "$raw" =~ ^[0-9]+$ ]]; then
            timestamp=$raw
        elif [[ -n "$raw" ]] && timestamp=$(date -d "$raw" +%s 2>/dev/null); then
            :
        else
            messages+=("$label: CRITICAL — timestamp is missing or unparseable in $file")
            set_status 2
            return
        fi
    else
        if ! timestamp=$(stat -c '%Y' -- "$file" 2>/dev/null); then
            messages+=("$label: CRITICAL — could not read file modification time: $file")
            set_status 2
            return
        fi
    fi

    if [[ ! "$timestamp" =~ ^[0-9]+$ ]]; then
        messages+=("$label: CRITICAL — invalid timestamp in $file")
        set_status 2
        return
    fi

    if (( timestamp > now )); then
        messages+=("$label: CRITICAL — timestamp is in the future: $file")
        set_status 2
        return
    fi

    age=$((now - timestamp))
    hours=$((age / 3600))
    minutes=$(((age % 3600) / 60))

    if (( age > CRIT_AGE_SECONDS )); then
        state="CRITICAL"
        code=2
    elif (( age > WARN_AGE_SECONDS )); then
        state="WARNING"
        code=1
    else
        state="OK"
        code=0
    fi

    messages+=("$label: $state — age ${hours}h ${minutes}m ($file)")
    set_status "$code"
}

check_file "Backup timestamp" \
    "$DUMP_DIR/${BACKUP_HOSTNAME}-backupflag" "content"

check_file "Dump marker" \
    "$DUMP_DIR/db_dumped.flag" "mtime"

case "$status" in
    0) overall="OK" ;;
    1) overall="WARNING" ;;
    2) overall="CRITICAL" ;;
    *) overall="UNKNOWN" ;;
esac

printf 'MySQL backup check: %s\n' "$overall"
printf ' - %s\n' "${messages[@]}"

exit "$status"
