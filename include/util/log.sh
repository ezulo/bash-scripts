#!/bin/echo Please-Source

#
# Logging for scripts, just source this file in the script
# Also prints logs via notify-send (libnotify required)
#
# `--notify-only` flag will waive printing the log to `stderr`.
#
# Usage:
# ```bash
# source $THIS_FILE
# ...
# "$SOME_CMD" || log_error $ID "Something went wrong: $?"
# log_info $ID "Stuff is happening!" --notify-only
# ```
#

! [ -z "$UTIL_LOG_SOURCED" ] && return 0
export UTIL_LOG_SOURCED=1

UTIL_DIR=${UTIL_DIR:-"$XDG_CONFIG_HOME/scripts/include/util"}
LOG_DIR=${LOG_DIR:-"$XDG_CONFIG_HOME/scripts/log"}
LL_FILE="$UTIL_DIR/log-level"

###############################################################################
## Configuration ##############################################################
###############################################################################

#
# Default log level (LL) and file logging
#
LL_DEFAULT=INFO
LL=$LL_DEFAULT
[ -f "$LL_FILE" ] && LL=$(cat "$LL_FILE")
LOG_TO_FILE=1

#
# Notification daemon backend commands (empty variable for log level = no-op)
#
NOTIFY_CMDS=(
    "" # ------------------------------- TRACE - #
    "" # ------------------------------- DEBUG - #
    "notify-send --urgency=low" # ------ INFO -- #
    "notify-send --urgency=normal" #---- WARN -- #
    "notify-send --urgency=normal" # --- ERROR - #
    "notify-send --urgency=critical" #-- FATAL - #
)

###############################################################################

# Use these functions
log_trace() { __log "TRACE" "$1" "$2" "$3" "$4"; }
log_info()  { __log "INFO"  "$1" "$2" "$3" "$4"; }
log_warn()  { __log "WARN"  "$1" "$2" "$3" "$4"; }
log_error() { __log "ERROR" "$1" "$2" "$3" "$4"; }
log_fatal() { __log "FATAL" "$1" "$2" "$3" "$4"; }
log_debug() { __log "DEBUG" "$1" "$2" "$3" "$4"; }

__log_level_value() {
    local OUT="-1"
    case $1 in
        TRACE) OUT=0; ;; DEBUG) OUT=1; ;; INFO) OUT=2 ;;
        WARN) OUT=3; ;; ERROR) OUT=4; ;; FATAL) OUT=5 ;;
    esac
    printf "%b" $OUT
}

__log_filter() {
    [ $(__log_level_value $LEVEL) -ge $(__log_level_value $LL) ] && return 0
    return 1
}

__log() {
    local LEVEL="$1"    && shift && ! __log_filter $LEVEL && return 0
    local ID="$1"       && shift
    local MSG="$1"      && shift
    local SILENT=$([[ "$@" =~ "--silent " ]] && echo 1)
    local LOG=("$ID:$LEVEL" "$MSG")
    local LOG_ECHO=$(sed -e 's/\\n/ /g' <<< "${LOG[0]} | ${LOG[1]}")
    local NOTIFY_CMD_IDX=$(__log_level_value "$LEVEL")
    local NOTIFY_CMD="${NOTIFY_CMDS[$NOTIFY_CMD_IDX]}"
    # Notify
    [ ! -z "$NOTIFY_CMD" ] && ($NOTIFY_CMD "${LOG[0]}" "${LOG[1]}")
    # Log to file (if provided)
    BASE_ID=$(echo "$ID" | cut -d ':' -f1)
    [ ! -z $LOG_TO_FILE ] && LOG_FILE="$LOG_DIR/$(date +%Y_%m_%d)_${BASE_ID}.log" &&
        echo "$(date +%Y_%m_%d\|%H:%M:%S)\|$LOG_ECHO" | tee -a "$LOG_FILE"
    # Log to stderr (unless --silent)
    [ -z "$SILENT" ] && echo "$LOG_ECHO" >&2
}

