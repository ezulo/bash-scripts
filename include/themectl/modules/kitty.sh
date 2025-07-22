#!/bin/echo Please-Source

ID_KITTY="$_ID:kitty"

TC_KITTY="$TC_DIR/kitty"
KITTY_CONFIG_DIR="${KITTY_CONFIG_DIR:-$XDG_CONFIG_HOME/kitty}"

# Private function; Generates kitty theme colors.conf
__colors_json_to_kitty_conf() {
    local ID="$ID_KITTY:$FUNCNAME"
    set -e
    local COLORS_JSON=$1
    local OUT_CONF=$2
    [ ! -f $COLORS_JSON ] &&
        log_warn $ID \
        "$COLORS_JSON not found. Ignoring kitty colors." \
    ||
        write_file_header "$OUT_CONF" "$COLORS_JSON" "conf"
        COLORBG=$(jq -r .[\"special\"].background $COLORS_JSON);
        [ "$COLORBG" != "null" ] &&
            echo -e "background\t\t$COLORBG" >> $OUT_CONF
        COLORFG=$(jq -r .[\"special\"].foreground $COLORS_JSON);
        [ "$COLORFG" != "null" ] &&
            echo -e "foreground\t\t$COLORFG" >> $OUT_CONF
        COLORSELBG=$(jq -r .[\"special\"].selection_background $COLORS_JSON);
        [ "$COLORSELBG" != "null" ] &&
            echo -e "selection_background\t$COLORSELBG" >> $OUT_CONF
        COLORSELFG=$(jq -r .[\"special\"].selection_foreground $COLORS_JSON);
        [ "$COLORSELFG" != "null" ] &&
            echo -e "selection_foreground\t$COLORSELFG" >> $OUT_CONF
        COLORCUR=$(jq -r .[\"special\"].cursor $COLORS_JSON);
        [ "$COLORCUR" != "null" ] &&
            echo -e "cursor\t\t\t$COLORCUR" >> $OUT_CONF
        for idx in $(seq 0 15); do
            COLOR=$(jq -r .[\"colors\"].color$idx $COLORS_JSON)
            [ "$COLOR" != "null" ] &&
                echo -e "color$idx\t\t\t$COLOR" >> $OUT_CONF
        done
}

kitty_theme() {
    local ID="$ID_KITTY:theme"
    local OUT_DIR="$KITTY_CONFIG_DIR/theme"
    local OUT_COLORS_CONF="$OUT_DIR/colors.conf"
    local TC_DIR="$THEME_HOME/kitty"
    [ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"
    [ -d "$TC_DIR" ] &&
        cp -r "$TC_DIR/kitty/"* "$KITTY_CONFIG_DIR/theme/" \
        ||
        log_warn $ID "Kitty config not found at $TC_DIR. Using defaults." &&
        cp -r ${TC_DEFAULT}/kitty/* "$KITTY_CONFIG_DIR/theme/"
    __colors_json_to_kitty_conf "$COLORS_JSON" "$OUT_COLORS_CONF"
}

kitty_reload() {
    local ID="$ID_KITTY:reload"
    # Ignore if command does not exist
    ! command -v kitty > /dev/null &&
        log_trace "$ID" "kitty not found." && return 1
    kill -SIGUSR1 $(pgrep kitty)
}

kitty_clean() {
    local ID="$ID_KITTY:clean"
    clear_dir "$KITTY_CONFIG_DIR/theme/"
    cp -r ${TC_DEFAULT}/kitty/* "$KITTY_CONFIG_DIR/theme/"
}

