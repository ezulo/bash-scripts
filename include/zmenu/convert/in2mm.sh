#!/usr/bin/env bash

in2mm() {
    local IN=$1
    [ -z $IN ] && return
    printf "%b\n" \
        $(bc <<< "$IN * 25.4")
}

