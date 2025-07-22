#!/bin/echo Please-Source

ID_ROFI="$_ID:rofi"

TC_ROFI="$TC_DIR/rofi"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$XDG_CONFIG_HOME/rofi}"

rofi_theme() {
    local ID="$ID_ROFI:theme"
    [ ! -d "$ROFI_CONFIG_DIR" ] &&
        log_warn $ID "Rofi config directory not found. Ignoring." && return 1
    local OUT_DIR="$ROFI_CONFIG_DIR/theme"
    local RASI_TMP="/tmp/theme_roficolors.rasi"
    local RASI_OUT="$OUT_DIR/colors.rasi"
    [ ! -d "$ROFI_CONFIG_DIR/theme" ] &&
        mkdir "$ROFI_CONFIG_DIR/theme"
    [ -f "$COLORS_JSON" ] &&
        echo "* {" > $RASI_TMP &&
        colors_to_css "$COLORS_JSON" "$RASI_TMP" "rasi" &&
        echo "}" >> $RASI_TMP &&
        commit_file "$RASI_TMP" "$RASI_OUT" \
        ||
		log_warn $ID "WARN: $COLORS_JSON not found. Ignoring rofi colors."
    [ -d "$TC_ROFI" ] &&
        log_warn $ID "Rofi configs not found. Using defaults."
        cp -r "$TC_ROFI/"* "$ROFI_CONFIG_DIR/theme/" \
        ||
        cp -r ${TC_DEFAULT}/rofi/* "$ROFI_CONFIG_DIR/theme/"
}

rofi_clean() {
    local ID="$ID_ROFI:clean"
    clear_dir "$ROFI_CONFIG_DIR/theme/"
}

rofi_reload() {
    local ID="$ID_ROFI:reload"
    echo "Nothing to do" > /dev/null
}

