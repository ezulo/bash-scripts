#!/usr/bin/env bash

# Maximum number of cached entries
CACHE_MAX_SZ=30

#DMENU_CMD="wofi --dmenu --cache-file=/dev/null"
#DMENU_CMD="kitty-cmd fzf"
DMENU_CMD="wmenu-wrapper"
KPROMPT_CMD="kitty-prompt"
FZF_CMD_FILES="fzf-files"
FZF_CMD_SELECT="fzf-select"

FZY_CMD_SELECT="fzy-select"

# An output file for subprocesses, so this script may see the output
SUB_OUT_FILE="$XDG_CACHE_HOME/zmenu.out"

d_read() {
    local ID="$1"
    local OPTS="$2"
    local PROMPT="$3"
    [ -z "$PROMPT" ] && PROMPT="$ID" || PROMPT="$ID | $PROMPT"
    echo -e "$OPTS" | $DMENU_CMD -p "$PROMPT" && return 0
    return 1
}

d_read_cached() {
    local ID="$1"
    local CACHE_ID="$2"
    local PROMPT="$3"
    local APPEND="$4" # "append" option to write to cache regardless of errors
    OPTS=$(_cache_read $CACHE_ID)
    [ -z $PROMPT ] && PROMPT="$ID" || PROMPT="$ID | $PROMPT"
    OUT=$(echo -e "$OPTS" | $DMENU_CMD -p "$PROMPT" | xargs)
    [ "$APPEND" = "append" ] && _cache_append "$ID/$CACHE_ID" "$OUT"
    printf "%b" "$OUT"
}

d_read_yes_no() {
    local ID="$1"
    local PROMPT="$2"
    local DEFAULT="[y|Y]"
    local OPTS="[Yes]\n[no]"
    [[ "$3" =~ ^[n|N] ]] && DEFAULT="[n|N]" && OPTS="[No]\n[yes]"
    OUT=$(echo -e "$OPTS" | $DMENU_CMD -p "$ID | $PROMPT" | xargs)
    RET=$?
    [ "$RET" != 0 ] && exit 1
    RE='^\['$DEFAULT'.*\]$'
    ! [[ "$OUT" =~ $RE ]] && return 1
    return 0
}

# Right now does nothing different
d_read_strict() {
    d_read "$1" "$2" "$3"
}

d_cache_append() {
    local ID="$1"
    local CACHE_ID="$2"
    local OUT="$3"
    _cache_append "$ID/$CACHE_ID" "$OUT"
}

# reads a single line of text from kitty prompt
k_read() {
    local ID="${1:-kitty-prompt}"
    local K_PROMPT="${2:-Enter input}"
    "$KPROMPT_CMD" "$ID" "$K_PROMPT"
}

k_read_silent() {
    local ID="${1:-kitty-prompt}"
    local K_PROMPT="${2:-Enter input}"
    "$KPROMPT_CMD" "$ID" "$K_PROMPT" silent
}

fzf_file_select() {
    local ID="$1"       && shift
    local PROMPT="$1"   && shift
    local SRC_DIR="$1"  && shift
    "$FZF_CMD_FILES" --title "$ID" --src "$SRC_DIR" --prompt "$PROMPT" --out "$SUB_OUT_FILE" "$@"
}

fzf_select() {
    local ID="$1"       && shift
    local PROMPT="$1"   && shift
    local OPTS="$1"     && shift
    "$FZF_CMD_SELECT" --title "$ID" --prompt "$PROMPT" --opts "$OPTS" --out "$SUB_OUT_FILE" "$@"
}

_cache_read_n() {
    local CACHE_ID=$1
    local READ_SZ=$2
    local FILE="$XDG_CACHE_HOME/$ID/$CACHE_ID"
    ! [ -f "$FILE" ] &&
        mkdir -p "$(dirname $FILE)" && touch "$FILE" && return 0
    cat "$FILE" | head -n "$READ_SZ"
}

_cache_read() {
    _cache_read_n "$1" "$CACHE_MAX_SZ"
}

_cache_append() {
    local FILE="$XDG_CACHE_HOME/$1"
    local OUT="$2"
    [ -z "$OUT" ] && return 1
    ! [ -f "$FILE" ] &&
        mkdir -p "$(dirname $FILE)" && touch "$FILE"
    local CACHE_DATA=$(
        _cache_read_n "$CACHE_ID" "$(($CACHE_MAX_SZ - 1))" | sed "\|^$OUT\$|d"
    )
    echo "$OUT" >  "$FILE"
    echo "$CACHE_DATA"   >> "$FILE"
}

