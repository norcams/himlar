#!/usr/bin/env bash
# check_images.sh
# ------------------------------------------------------------
# Exit codes
#   0 – success
#   1 – error (failed images or result older than 7 days)
#   2 – warning (skipped images, but no failures)
#   3 – invalid JSON
# ------------------------------------------------------------

set -u               # treat unset variables as an error
export LC_ALL=C      # force a predictable locale for date parsing

# -----------------------------------------------------------------
# 1. Input handling
# -----------------------------------------------------------------
JSON_FILE="${1:-/var/log/imagebuilder/result.json}"

if [[ ! -f "$JSON_FILE" ]]; then
    echo "error: file not found: $JSON_FILE"
    exit 1
fi

# -----------------------------------------------------------------
# 2. Validate that the json file
# -----------------------------------------------------------------
if ! jq_output=$(jq empty "$JSON_FILE" 2>&1); then
    echo "result is not valid json"
    echo "$jq_output"
    exit 3
fi

# -----------------------------------------------------------------
# 3. Extract fields (all extractions are guarded – a malformed
#     field will cause a clear error message and exit 1)
# -----------------------------------------------------------------
#   a) date
date_value=$(jq -er '
    .date
    | select(type == "string")
' "$JSON_FILE") || {
    echo "error: missing or non‑string \"date\" field"
    exit 1
}

#   b) failed_images (as an array, count only)
failed_count=$(jq -er '
    (.failed_images // [])
    | if type == "array" then length else error end
' "$JSON_FILE") || {
    echo "error: \"failed_images\" must be an array"
    exit 1
}

#   c) skipped_images (as an array, count only)
skipped_count=$(jq -er '
    (.skipped_images // [])
    | if type == "array" then length else error end
' "$JSON_FILE") || {
    echo "error: \"skipped_images\" must be an array"
    exit 1
}

# -----------------------------------------------------------------
# 4. Date sanity check (must be a real date)
# -----------------------------------------------------------------
if ! date -u -d "$date_value" "+%F" >/dev/null 2>&1; then
    echo "error: invalid date value \"$date_value\""
    exit 1
fi

# The oldest acceptable date is 7 calendar days ago (inclusive)
cutoff_date=$(date -u -d "7 days ago" "+%F")

# -----------------------------------------------------------------
# 5. Decision logic – highest priority first
# -----------------------------------------------------------------
# 5.1 Failed images -> error
if (( failed_count > 0 )); then
    echo "critical"
    echo "Failed images:"
    jq -r '(.failed_images // [])[]' "$JSON_FILE"
    exit 1
fi

# 5.2 Date older than 7 days -> error
if [[ "$date_value" < "$cutoff_date" ]]; then
    echo "critical"
    echo "Last run date is too old: $date_value"
    echo "Expected a date on or after: $cutoff_date"
    exit 1
fi

# 5.3 Skipped images (only reached if no failures) -> warning
if (( skipped_count > 0 )); then
    echo "warning"
    echo "Skipped images:"
    jq -r '(.skipped_images // [])[]' "$JSON_FILE"
    exit 2
fi

# 5.4 All checks passed -> success
echo "success"
echo "all images built successfully"
exit 0
