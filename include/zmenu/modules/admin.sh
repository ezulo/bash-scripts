#!/bin/echo Please-Source

ID="$_ID:admin"

OPTS="\
clear zmenu cache"

kitty_callback() {
    CMD="fzf-select $1 $2 $@"
}

OPT=$(fzf_select "$ID" "What would you like to do?" "$OPTS")

case $OPT in
    clear*)
        rm -rf "$HOME/.cache/zmenu:"*
        log_info "$ID" "zmenu cache cleared"
        ;;
    *)
        exit 1
esac

