#!/usr/bin/env bash

divide_by_thousand() {
    local NUM="$1"
    local LEN="${#NUM}"
    if (( $LEN <= 3 )); then
        printf "0.%03d in.\n" "$NUM"
    else
        NUM_INT="${NUM:0:LEN-3}"
        NUM_FRACT="${NUM: -3}"
        printf "%b.%b" "$NUM_INT" "$NUM_FRACT"
    fi
}

mm2in() {
    local MM=$1
    [ -z $MM ] && return
    divide_by_thousand $(bc <<< "($MM * 1000) / 25.4")
}

