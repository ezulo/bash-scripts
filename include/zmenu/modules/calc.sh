#!/bin/echo Please-Source

ID="$_ID:calc"

# Backend can be changed, though usage below must be adapted
BACKEND=/usr/bin/bc
! command -v "$BACKEND" > /dev/null &&
    log_error "$ID" "$BACKEND not found." && exit 1

PROMPT="Enter a calculation"
CALC=$(d_read_cached "$ID" "history" "$PROMPT")
[ -z "$CALC" ] && exit 1

RES=$(echo "$CALC" | "$BACKEND" 2>&1)

[[ "$RES" == *"error"* ]] &&
    log_error "$ID" "Error: could not calculate." && exit 1

echo -n "$RES" | wl-copy
d_cache_append "$ID" "history" "$CALC"

log_info "$ID" "$CALC =\n$RES\n\n(copied to clipboard)"

