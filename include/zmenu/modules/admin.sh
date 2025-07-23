#!/bin/echo Please-Source

OPTS="\
clear zmenu cache"

OPT=$(d_read "$ID" "$OPTS" "What would you like to do?")

case $OPT in
    clear*)
        rm -rf "$HOME/.cache/zmenu:"*
        notify-send "$ID:LOG" "zmenu cache cleared"
        ;;
    *)
        exit 1
esac

