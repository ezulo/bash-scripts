#!/bin/echo Please-Source

ID_DUNST="${_ID}:dunst"

TC_DUNST="$TC_DIR/dunst"
DUNST_CONFIG_DIR="${DUNST_CONFIG_DIR:-$XDG_CONFIG_HOME/dunst}"

_dunst_checksum() {
    local IN_FILE="$1"
    log_trace $ID_DUNST "$(cat "$IN_FILE" | 
            grep -v '^\s*;' | 
            grep -v '^$')"
    cat "$IN_FILE" | 
        grep -v '^\s*;' | 
        grep -v '^$' |
        sha256sum |
        cut -d " " -f1
}

dunst_theme() {
    local ID="$ID_DUNST:theme"
    [ ! -d "$DUNST_CONFIG_DIR" ] &&
        log_error $ID \
        "dunst module active, but directory not found: $DUNST_CONFIG_DIR." &&
        return 1
    TMP=$(mktemp)
    log_trace $ID "Temp file made: $TMP"
    write_file_header "$TMP" "$DUNST_CONFIG_DIR" "dunst"
    OUT="$DUNST_CONFIG_DIR/dunstrc"
    [ ! -f "$OUT" ] && touch "$OUT"
    cat "$DUNST_CONFIG_DIR/dunstrc.default" >> "$TMP"
    sleep 0.1
    [ ! -d "$TC_DUNST" ] && TC_DUNST="$TC_SKELETON/dunst"

    for INFILE in ${TC_DUNST}/*; do
        echo "; Theme Config Start [$THEME]" >> "$TMP"
        echo "; $INFILE" >> "$TMP"
        cat "$INFILE" >> "$TMP"
        echo -e "; END FILE\n" >> "$TMP"
    done

    DUNST_SUM_NEW=$(_dunst_checksum "$TMP")
    # Run a sha256sum check, to avoid restarting unnecessarily
    [ "$DUNST_SUM_NEW" != "$DUNST_SUM" ] &&
        commit_file "$TMP" "$OUT" &&
        log_info $ID \
            "Dunst config change detected. Waiting for messages to clear..." &&
        while [ $(dunstctl "count" "displayed") -gt 0 ]; do sleep 0.1; done &&
        killall dunst && sleep 0.1
}

dunst_reload() {
    local ID="$ID_DUNST:reload"
    # We only reload dunst if necessary in the `dunst_theme` function
    return 0
}

dunst_clean() {
    local ID="$ID_DUNST:clean"
    DUNST_SUM=$(_dunst_checksum "$DUNST_CONFIG_DIR/dunstrc")
}

