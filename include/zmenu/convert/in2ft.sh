#!/usr/bin/env bash

in2ft() {
    local IN=$1
    [ -z $IN ] && return
    printf "%b'%b\"\n" \
        $(bc <<< "$IN / 12") \
        $(bc <<< "$IN % 12")
    cache_append "$FUNCNAME" "$IN"
}

