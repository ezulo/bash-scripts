#!/bin/echo Please-Source

ID="$_ID:theme"

# Const
LFS='
'
OPTS="get\nset\nreload\nclear\ncreate\ntoggle wallpapers"

THEMECTL="$XDG_CONFIG_HOME/scripts/themectl"
THEME_HOME="$XDG_CONFIG_HOME/theme"
export THEME=$(cat "$THEME_HOME/current-theme")

TERMINAL="kitty"
EDITOR="nvim"

OPT=$(d_read "$ID" "$OPTS")
[ -z "$OPT" ] && exit 1

AV_THEMES="$($THEMECTL ls)"

case $OPT in
    get)
        ID="$ID:get"
        ;;
    set)
        ID="$ID:set"
        THEME_OPT=$(d_read "$ID" "$AV_THEMES" "set theme")
        [ -z $(echo "$AV_THEMES" | grep "^$THEME_OPT\$") ] &&
            log_error "$ID" "Theme not found: $THEME_OPT" && exit 1
        $("$THEMECTL" set "$THEME_OPT")
        ;;
    reload)
        ID="$ID:reload"
        "$THEMECTL" reload
        ;;
    clear)
        ID="$ID:clear"
        "$THEMECTL" clear
        ;;
    create)
        ID="$ID:create"
        SRC_THEME=
        d_read_yes_no "$ID" "duplicate existing?" &&
            SRC_THEME=$(d_read "$ID" "$AV_THEMES" "source theme") &&
            [ -z $(echo "$AV_THEMES" | grep "^$SRC_THEME\$") ] &&
                log_error "$ID" "Theme not found: $THEME_OPT" && exit 1
        NEW_THEME=$(k_read "$ID" "What would you like to name your new theme?")
        [ -z "$NEW_THEME" ] && log_error "$ID" "Theme name was empty." && exit 1
        "$THEMECTL" create "$NEW_THEME" "$SRC_THEME" &&
        "$TERMINAL" "$EDITOR" "$THEME_HOME/$NEW_THEME"
        ;;
    'toggle wallpapers')
        ID="$ID:toggle_wallpapers"
        "$THEMECTL" toggle-wallpapers
        ;;
    *)
        log_error "$ID" "Unrecognized option: $OPT" && exit 1
        ;;
esac

