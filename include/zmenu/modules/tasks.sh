#!/bin/echo Please-Source

export ZEIT_DB="$XDG_CONFIG_HOME/zeit/zeit.db"
ZEIT_CMD="$HOME/.local/bin/zeit"
ZEIT_GET="$XDG_CONFIG_HOME/scripts/zeit-get"

BEGIN_OPTS="\
now
+1:30
+1:00
+0:45
+0:30
+0:15
+0:05
+0:01
-0:01
-0:05
-0:15
-0:30
-0:45
-1:00
-1:30"

poll_zeit() {
    if "$ZEIT_GET"; then
        return 0
    fi
    return 1
}
 
if poll_zeit; then
    Z_TASK=$("$ZEIT_GET" task)
    Z_PROJ=$("$ZEIT_GET" proj)
    Z_TIME=$("$ZEIT_GET" time)
    Z_STRING="$Z_TASK on $Z_PROJ @ $Z_TIME"
    if ! d_read_yes_no "$ID" \
        "[ $Z_PROJ / $Z_TASK ] Finish the current task?"; then
        exit 1
    fi
    set +e 
    OUT=$("$ZEIT_CMD" finish)
    RET=$?
    [ ! $RET = 0 ] && exit 1
    log_info "$ID" "zeit task finished:\n$Z_STRING"
    if ! d_read_yes_no "$ID" "Start tracking a new task?"; then 
        exit 0; 
    fi
fi

PROJECT=$(d_read_cached "$ID" "projects" "[ _ / _ ] Enter a Project:")
[ -z "$PROJECT" ] && log_error "$ID" "No project selected" && exit 1

TASK=$(d_read_cached "$ID" "${PROJECT}/tasks" "[ $PROJECT / _ ] Enter a Task:")
[ -z "$TASK" ] && log_error "$ID" "No task selected" && exit 1

BEGIN=$(d_read "$ID" "$BEGIN_OPTS" "[ $PROJECT / $TASK ] Begin when?")
[ -z "$BEGIN" ] && BEGIN="now"

"$ZEIT_CMD" track --project "$PROJECT" --task "$TASK" --begin "$BEGIN"
log_info "$ID"
    "New task started:\nProject: $PROJECT\nTask: $TASK\nBegin: $BEGIN"

