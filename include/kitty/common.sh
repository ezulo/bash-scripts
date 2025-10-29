#!/bin/echo PleaseSource

#
# Utilities for kitty-(cmd|edit|prompt)
# 

ID="kitty-"
DEFAULT_WINDOW_WIDTH=800
DEFAULT_WINDOW_HEIGHT=800

kitty_close_all() {
    hyprctl dispatch killwindow "class:kitty-.*" > /dev/null 2>&1
}

# Unknown if this is needed, but keeping it around
kill_on_unfocus() (
    SOCAT_PNAME="socat_kitty_listener"
    handle() {
        case "$1" in
            "activewindow>>"*)
                ! [[ "$1" =~ "activewindow>>kitty-cmd," ]] && 
                    kitty_close_all && pkill -f "$SOCAT_PNAME" 2> /dev/null
                ;;
        esac
    }
    exec -a "$SOCAT_PNAME" socat -U \
        - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | \
        while read -r line; do handle "$line"; done
)

kitty_spawn() {
    kitty_close_all
    local WINDOW_CLASS="$1" && shift
    local WINDOW_WIDTH="${1:-${DEFAULT_WINDOW_WIDTH}}" && shift
    local WINDOW_HEIGHT="${1:-${DEFAULT_WINDOW_HEIGHT}}" && shift
    local CMD="$1" && shift
    [ -z "$CMD" ] && return 1
    local OVERRIDE=(
        "--override=map Ctrl+Esc close"
        "--override=confirm_os_window_close 0"
        "--override=initial_window_width $WINDOW_WIDTH"
        "--override=initial_window_height $WINDOW_HEIGHT"
    )
    while ! [ -z "$1" ]; do OVERRIDE+=("--override=\"$1\"") && shift; done
    kitty --class "$WINDOW_CLASS" "${OVERRIDE[@]}" bash -c "$CMD" > /dev/null 2>&1
}

