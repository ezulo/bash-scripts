#!/bin/echo Please-Source

ID="$_ID:audio"

MENU_PROMPT="Select an audio sink"

# get list of sinks
SINKS_RAW=$(wpctl status)
SINKS_LN=$(echo "$SINKS_RAW" | grep -n -m 1 "Sinks:" | cut -f1 -d:)
SINKS_LN_END=$((
    $(echo "$SINKS_RAW" | grep -n -m 1 "Sources:" | cut -f1 -d:) -2
))
SINKS_TRIM=$(\
    echo "$SINKS_RAW" | \
    head -n $SINKS_LN_END | \
    tail -n $(($SINKS_LN_END - $SINKS_LN)) \
)
SINKS=""
while IFS= read -r LINE; do
    SINKS="$(echo "$LINE" | cut -c 10- | rev | cut -c 12- | rev)\n${SINKS}"
done <<< "$SINKS_TRIM"

OPT=$(d_read "$ID" "$SINKS" "$MENU_PROMPT")

# set new default

NEW_DEFAULT=$(echo $OPT | cut -d "." -f1)
NAME=$(echo $OPT | cut -d "." -f2 | xargs)
! wpctl set-default $NEW_DEFAULT &&
    log_error "$ID" "There was an error setting the sink: $?" && exit 1

log_info "$ID" "Set default sink to:\n$NAME"

