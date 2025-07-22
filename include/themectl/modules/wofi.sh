#!/bin/echo Please-Source

ID_WOFI="$_ID:wofi"
WOFI_CONFIG_DIR="${WOFI_CONFIG_DIR:-$XDG_CONFIG_HOME/wofi}"

wofi_theme() {
    local ID="$ID_WOFI:theme"
    local TC_WOFI="$TC_DIR/wofi"
    [ ! -d "$WOFI_CONFIG_DIR" ] &&
        log_warn $ID "Wofi config directory not found. Ignoring." && return 1
    [ ! -d "$TC_WOFI" ] && 
        log_warn $ID "Wofi config directory missing. Using defaults." &&
        TC_WOFI="$TC_DEFAULT/wofi"
    local OUT_DIR="$WOFI_CONFIG_DIR/theme"
    local OUT_COLORS_CSS="$OUT_DIR/colors.css"
    [ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"
    [ -f "$COLORS_JSON" ] &&
        colors_to_css "$COLORS_JSON" "$OUT_COLORS_CSS" \
    ||
		log_warn $ID "$COLORS_JSON not found. Ignoring wofi colors."
    for TC_FILE in "$TC_WOFI"/*; do
        local FILE_OUT="$OUT_DIR/$(basename $TC_FILE)"
        sed 's|{_COLORS_CSS_}|'$OUT_COLORS_CSS'|' "$TC_FILE" >> "$FILE_OUT"
    done
}

wofi_clean() {
    local ID="$ID_WOFI:clean"
    clear_dir "$WOFI_CONFIG_DIR/theme/"
    cp -r ${TC_DEFAULT}/wofi/* "$WOFI_CONFIG_DIR/theme/"
}

wofi_reload() {
    local ID="$ID_WOFI:reload"
    log_trace $ID "Nothing to do"
}

