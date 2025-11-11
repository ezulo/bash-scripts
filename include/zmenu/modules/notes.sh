#!/bin/echo Please-Source

ID="$_ID:notes"

# Const
HYPR_TERMINAL=${HYPR_TERMINAL:-kitty}
NOTES_DIR=${NOTES_DIR:-$HOME/Notes}
[ ! -d "$NOTES_DIR" ] && mkdir -p "$NOTES_DIR"

CREATE_NEW="[ Create new... ]"
LS_NOTES="$CREATE_NEW\n"

OPT=$(fzf_file_select \
    "Notes" "Select a Note" "$NOTES_DIR" --opt "$CREATE_NEW" \
    --preview "cat $NOTES_DIR/{} 2> /dev/null || echo {}")

[ -z "$OPT" ] && exit 1
FILE="$OPT"

# Default (create file with timestamp)
[[ "$OPT" == "$CREATE_NEW" ]] && 
    FILE=$(k_read "$ID" "Select a filename (or leave blank)") &&
    [ -z "$FILE" ] &&
    echo "timestamping" &&
    FILE=$(date +"%Y-%m-%dT%H:%M:%S%z").md

# Append md extension if missing
[[ ! "$FILE" =~ \.md$ ]] && FILE=$FILE.md

# Try to write directory, if relevant
! [ -d $(dirname "$FILEPATH") ] && ! mkdir -p $(dirname "$FILEPATH") && 
    log_error "$ID" "Could not create parent directory for $FILEPATH" && exit 1

kitty-edit "$NOTES_DIR/$FILE"

