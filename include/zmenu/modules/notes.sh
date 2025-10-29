#!/bin/echo Please-Source

ID="$_ID:notes"

echo "$ID"
echo "hello world"

# Const
HYPR_TERMINAL=${HYPR_TERMINAL:-kitty}
NOTES_DIR=${NOTES_DIR:-$HOME/Notes}
[ ! -d "$NOTES_DIR" ] && mkdir -p "$NOTES_DIR"
echo "hello world"

CREATE_NEW="New..."
LS_NOTES=$(ls -t --color=none -1 "$NOTES_DIR")
OPT=$(d_read "$ID" "$CREATE_NEW\n$LS_NOTES")
echo "hello world"
[ -z "$OPT" ] && exit 1
NOW=$(date +"%Y-%m-%dT%H:%M:%S%z")

FILE="$OPT"

# Default (create file with timestamp)
[[ "$OPT" == "$CREATE_NEW" ]] && FILE=$NOW.md

# Append md extension if missing
[[ ! "$FILE" =~ \.md$ ]] && FILE=$FILE.md

#$HYPR_TERMINAL nvim $NOTES_DIR/$FILE
kitty-edit "$NOTES_DIR/$FILE"

