#!/bin/echo PleaseSource

#
# Utilities for kitty-(cmd|edit|prompt)
# 

_ID="kitty"
DEFAULT_WINDOW_WIDTH=800
DEFAULT_WINDOW_HEIGHT=800

CMD_QUEUE=()

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
    local WINDOW_CLASS="${ID:-"${_ID}"}"
    local WINDOW_WIDTH="$DEFAULT_WINDOW_WIDTH"
    local WINDOW_HEIGHT="$DEFAULT_WINDOW_HEIGHT"
    local KITTY_FLAGS=()
    while ! [ -z "$1" ]; do
        [ "$1" == "--" ] && shift && break
        case "$1" in
            '--width='*)
                WINDOW_WIDTH=$(cut -d '=' -f2 <<< "$1")
                ;;
            '--height='*)
                WINDOW_HEIGHT=$(cut -d '=' -f2 <<< "$1")
                ;;
            '--class='*)
                WINDOW_CLASS=$(cut -d '=' -f2 <<< "$1")
                ;;
            *)
                KITTY_FLAGS+=("$1"); 
                ;;
        esac
        shift
    done
    KITTY_FLAGS+=(
        "--override=map Ctrl+Esc close"
        "--override=confirm_os_window_close 0"
        "--override=initial_window_width $WINDOW_WIDTH"
        "--override=initial_window_height $WINDOW_HEIGHT"
    )
    kitty -1 --class $WINDOW_CLASS "${KITTY_FLAGS[@]}" "$@"
}

