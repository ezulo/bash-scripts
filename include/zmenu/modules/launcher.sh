#!/bin/echo Please-Source

ID="$_ID:launcher"
ARG="$1" && shift
OPTS_FILE="${1:-$ZMENU_INCLUDE_DIR/launcher/options}" && shift
OPTS_FILE_BACKUP="${1:-$ZMENU_INCLUDE_DIR/launcher/options_backup}"

[ ! -d "$(dirname "$OPTS_FILE")" ] &&
    mkdir "$(dirname "$OPTS_FILE")" 
[ ! -d "$(dirname "$OPTS_FILE_BACKUP")" ] &&
    mkdir "$(dirname "$OPTS_FILE_BACKUP")" 

trim_whitespace() {
    while IFS= read -r LINE; do
        echo "$LINE" | awk '{$1=$1;print}'
    done
}

get_opts() {
    local FLAG="$1"
    local CUT="cat"
    [ "$1" == "--name" ] && CUT="cut -d: -f1"
    [ "$1" == "--cmd" ] && CUT="cut -d: -f2"
    while IFS= read -r LINE; do
        echo "$LINE" | $CUT | trim_whitespace 
    done < "$OPTS_FILE"
}

lookup_opt() {
    local OPT_NAME="$1"
    local CUR_NAME=
    local CUR_CMD=
    while IFS= read -r LINE; do
        CUR_NAME=$(echo "$LINE" | cut -d: -f1 | trim_whitespace)
        CUR_CMD=$(echo "$LINE" | cut -d: -f2 | trim_whitespace)
        [ "$OPT_NAME" == "$CUR_NAME" ] && echo "$CUR_CMD" && return 0
    done < "$OPTS_FILE"
    return 1
}

update_opts() {
    local IN_BUF="$1"
    local TMP=$(mktemp)
    local NAME=
    local CMD=
    echo "$IN_BUF" | sed -e "/###.*###/d" > "$TMP"
    [ -z "$(cat $TMP)" ] && log_info "$ID" "Aborted." && return 0
    mv "$OPTS_FILE" "$OPTS_FILE_BACKUP"
    touch "$OPTS_FILE"
    while IFS= read LINE; do
        NAME=$(echo $LINE | cut -d':' -f1 | trim_whitespace)
        CMD=$(echo $LINE | cut -d':' -f2 | trim_whitespace)
        [ -z "$NAME" ] && continue
        [ -z "$CMD" ] && CMD="$NAME"
        printf "%s: %s\n" "$NAME" "$CMD" >> "$OPTS_FILE"
    done < "$TMP"
    log_info "$ID" "Launcher updated."
    rm "$TMP"
}

editor_header() {
    echo "#####################################################"
    echo "###             ZMENU:LAUNCHER CONFIG             ###"
    echo "### _____________________________________________ ###"
    echo "### Add / edit entries in the following format:   ###"
    echo "### option1: command1                             ###"
    echo "### option2: command2                             ###"
    echo "### etc...                                        ###"
    echo "###                                               ###"
    echo "### Or simply enter the name of the command:      ###"
    echo "### command3                                      ###"
    echo "### command4                                      ###"
    echo "### etc...                                        ###"
    echo "#####################################################"
    echo "### A backup file will be created on edit.        ###"
    echo "### To abort, close this buffer.                  ###"
    echo "#####################################################"
    echo ""
}

config_mode() {
    local ID="$ID:config"
    local TMP_FILE=$(mktemp)
    local SUBOPT=$(d_read "$ID" "edit\nrestore backup")
    case $SUBOPT in
        edit)
            editor_header       >  "$TMP_FILE"
            get_opts            >> "$TMP_FILE"
            update_opts         "$(kitty-edit "$TMP_FILE" "-c $")"
            rm "$TMP_FILE"
            ;;
        restore*)
            cp "$OPTS_FILE_BACKUP" "$OPTS_FILE" && log_info "$ID" "Backup restored."
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

launcher_mode() {
    local ID="$ID"
    local LAUNCHER_NAMES=$(get_opts --name)
    local OPT=$(d_read "$ID" "$LAUNCHER_NAMES")
    [ -z "$OPT" ] && return 1
    local CMD=$(lookup_opt "$OPT" || log_info "$ID" "error")
    [ -z "$CMD" ] && return 1
    $CMD 2> /tmp/vimout
    #exec $CMD > /dev/null 2>&1 & disown
}

[ "$ARG" == "--config" ] && config_mode
[ -z "$ARG" ]          && launcher_mode

