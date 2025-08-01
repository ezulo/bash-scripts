#!/bin/echo Please-Source

ID_WAYBAR="_ID:waybar"

TC_WAYBAR="$TC_DIR/waybar"
WAYBAR_CONFIG_DIR="${WAYBAR_CONFIG_DIR:-$XDG_CONFIG_HOME/waybar}"

waybar_theme() {
    local ID="$ID_WAYBAR:theme"
    [ ! -d "$WAYBAR_CONFIG_DIR" ] &&
        log_error $ID "Waybar config directory missing: $WAYBAR_CONFIG_DIR" &&
        return 1
    local OUT_DIR="$WAYBAR_CONFIG_DIR/theme"
    local CSS_OUT="$OUT_DIR/colors.css"
    [ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"
    [ ! -f "$COLORS_JSON" ] &&
		log_warn $ID "$COLORS_JSON not found. Ignoring waybar colors." \
        ||
        write_file_header "$CSS_OUT" "$COLORS_JSON" "css" &&
        colors_to_css "$COLORS_JSON" "$CSS_OUT"
    [ ! -d "$TC_WAYBAR" ] && 
        log_warn $ID "Waybar configs for theme not found. Using defaults." &&
        commit_dir "$TC_SKELETON/waybar" "$OUT_DIR" && return 0
    commit_dir "$TC_WAYBAR" "$OUT_DIR"
}

waybar_reload() {
    local ID="$ID_WAYBAR:reload"
    # Ignore if command does not exist
    if ! command -v waybar > /dev/null; then
        log_error $ID "waybar command does not exist!"
        return 1
    fi
	[[ ! -z $(pgrep -x "waybar") ]] && killall waybar
	waybar > /dev/null 2>&1 &
}

waybar_clean() {
    local ID="$ID_WAYBAR:clean"
    clear_dir "$WAYBAR_CONFIG_DIR/theme/"
}

