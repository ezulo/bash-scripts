#!/bin/echo Please-Source

ID_HYPRLAND="$_ID:hyprland"

TC_HYPRLAND="$TC_DIR/hyprland"
HYPR_CONFIG_DIR="${HYPR_CONFIG_DIR:-$XDG_CONFIG_HOME/hypr}"

if [ ! -d "$HYPR_CONFIG_DIR" ]; then
    >&2 echo "Hyprland config directory missing! Is it installed?"
    >&2 echo "Please install and set the HYPR_CONFIG_DIR environment variable."
    exit 1
fi

TMP_DIR="/tmp/theme_hyprland"
OUT_DIR="$HYPR_CONFIG_DIR/theme"
[ ! -d "$TMP_DIR" ] && mkdir "$TMP_DIR"
[ ! -d "$OUT_DIR" ] && mkdir "$OUT_DIR"

# Commits our config files to a tmp directory, because hyprland spams errors if
# you try to directly write them before reloading. We commit them during reload.
hyprland_theme() {
    local ID="$ID_HYPRLAND:theme"
    local SRC_DIR="$TC_HYPRLAND"
    if [ ! -d "$TC_HYPRLAND" ]; then
        log_warn $ID \
            "hyprland files missing:\n$TC_HYPRLAND.\nUsing default config."
        SRC_DIR="$TC_SKELETON/hyprland"
        return 0
    fi
    clear_dir  "$TMP_DIR"
    commit_dir "$SRC_DIR" "$TMP_DIR"
}

hyprland_reload() {
    ID="$ID_HYPRLAND:reload"
    clear_dir "$OUT_DIR"
    commit_dir "$TC_HYPRLAND" "$OUT_DIR"
    clear_dir "$TMP_DIR"
    hyprctl reload > /dev/null 2>&1
}

hyprland_clean() {
    ID="$ID_HYPRLAND:clean"
    log_debug $ID "Nothing done."
}

