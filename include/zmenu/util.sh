#!/usr/bin/env bash

# Maximum number of cached entries
CACHE_MAX_SZ=30

DMENU_CMD="wofi --dmenu"
KPROMPT_CMD="kitty-prompt"

# dmenu-like read
d_read() {
    local ID="$1"
    local OPTS="$2"
    local MENU_PROMPT="$3"
    local CMD=${4:-$DMENU_CMD}
    echo -e "$OPTS" | $CMD -p "$ID | $MENU_PROMPT"
}


d_read_cached() {
    local ID="$1"
    local CACHE_ID="$2"
    local MENU_PROMPT="$3"
    local CMD=${4:-$DMENU_CMD}
    OPTS=$(cache_read $CACHE_ID)
    OUT=$(echo -e "$OPTS" | $CMD -p "$ID | $MENU_PROMPT")
    cache_append "$CACHE_ID" "$OUT"
    printf "%b" "$OUT"
}

d_read_yes_no() {
    local ID="$1"
    local MENU_PROMPT="$2"
    local CMD=${3:-$DMENU_CMD}
    local DEFAULT="[y|Y]"
    [[ "$4" =~ ^[n|N] ]] && DEFAULT="[n|N]"
    echo "hello! $DEFAULT"
    OUT=$(echo -e "[Yes]\n[No]" | $CMD --insensitive -p "$ID | $MENU_PROMPT")
    RET=$?
    echo "goodbye!"
    [ "$RET" != 0 ] && exit 1
    RE='^\['$DEFAULT'.*\]$'
    if [[ "$OUT" =~ $RE ]]; then echo "match" && return 0; fi
    echo "nomatch $RET / $OUT ($RE)" && return 1
}

# Right now does nothing different
d_read_strict() {
    d_read "$1" "$2" "$3"
}

# reads a single line of text from kitty prompt
k_read() {
    local ID="$1"
    local K_PROMPT="$2"
    local TMP="/tmp/t_read_temp"
    rm -f "$TMP"
    "$KPROMPT_CMD" "$ID" "$K_PROMPT"
}

cache_read_n() {
    local CACHE_ID=$1
    local READ_SZ=$2
    local CACHE_FILE="$XDG_CACHE_HOME/$ID/$CACHE_ID"
    [ ! -f "$CACHE_FILE" ] && touch "$CACHE_FILE" && return 0
    cat "$CACHE_FILE" | head -n "$READ_SZ"
}

cache_read() {
    cache_read_n "$1" "$CACHE_MAX_SZ"
}

cache_append() {
    local CACHE_ID="$1"
    local CACHE_NEW_ITEM="$2"
    local CACHE_FILE="$XDG_CACHE_HOME/$ID/$CACHE_ID"
    [ -z "$CACHE_NEW_ITEM" ] && return 1
    if [ ! -f "$CACHE_FILE" ]; then
        mkdir -p "$(dirname $CACHE_FILE)" && touch "$CACHE_FILE"
    fi
    local CACHE_STREAM=$(
        cache_read "$CACHE_ID" "$(($CACHE_MAX_SZ + 1))" | sed "/$CACHE_NEW_ITEM/d")
    echo "$CACHE_NEW_ITEM" >  "$CACHE_FILE"
    echo "$CACHE_STREAM"   >> "$CACHE_FILE"
}

