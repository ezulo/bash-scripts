#!/bin/echo Please-Source

ID="$_ID:session"

OPTS="\
logout
lock
sleep
shutdown
reboot"

OPT=$(d_read "$ID" "$OPTS")

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

