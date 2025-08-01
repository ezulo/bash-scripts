#!/bin/echo Please-Source

ID="$_ID:session"

MENU_PROMPT="What would you like to do, $USER?"

OPTS="\
logout
lock
sleep
shutdown
reboot"

OPT=$(d_read "$ID" "$OPTS" "$MENU_PROMPT")

case $OPT in
    "logout")
        hyprctl dispatch exit
        ;;
    "lock")
        hyprlock
        ;;
    "sleep")
        systemctl suspend
        ;;
    "shutdown")
        shutdown -ah now
        ;;
    "reboot")
        shutdown -ar now
        ;;
    *)
        exit 1
esac

