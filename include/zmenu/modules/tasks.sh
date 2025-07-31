#!/bin/echo Please-Source

export ZEIT_DB="$XDG_CONFIG_HOME/zeit/zeit.db"
ZEIT_CMD="$HOME/.local/bin/zeit"
ZEIT_GET="$XDG_CONFIG_HOME/scripts/zeit-get"

! [ -f "$ZEIT_CMD" ] && log_error "zeit not found: $ZEIT_CMD"
! [ -f "$ZEIT_GET" ] && log_error "zeit-get not found: $ZEIT_GET"

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

prompt_finish_task() {
    local Z_TASK=$("$ZEIT_GET" task)
    local Z_PROJ=$("$ZEIT_GET" proj)
    local Z_TIME=$("$ZEIT_GET" time)
    local Z_STRING="$Z_TASK on $Z_PROJ @ $Z_TIME"
    ! d_read_yes_no "$ID" "[ $Z_PROJ / $Z_TASK ] Finish task?" && exit 1
    OUT=$("$ZEIT_CMD" finish) &&
    RET=$? &&
    [ ! $RET = 0 ] && return 1
    log_info "$ID" "zeit task finished:\n$Z_STRING"
    d_read_yes_no "$ID" "Start tracking a new task?" && return 0; 
    return 1
}

"$ZEIT_GET" && { prompt_finish_task || exit 0; }

PROJECT=$(d_read_cached "$ID" "projects" "[ _ / _ ] Enter a Project:")
[ -z "$PROJECT" ] && log_error "$ID" "No project selected" && exit 1


TASK=$(d_read_cached "$ID" "${PROJECT}/tasks" "[ $PROJECT / _ ] Enter a Task:")
[ -z "$TASK" ] && log_error "$ID" "No task selected" && exit 1

BEGIN=$(d_read "$ID" "$BEGIN_OPTS" "[ $PROJECT / $TASK ] Begin when?")
[ -z "$BEGIN" ] && BEGIN="now"


"$ZEIT_CMD" track --project "$PROJECT" --task "$TASK" --begin "$BEGIN" &&
    d_cache_append "$ID" "projects" "$PROJECT" &&
    d_cache_append "$ID" "$PROJECT/tasks" "$PROJECT" &&
    log_info "$ID" \
        "New task started:\nProject: $PROJECT\nTask: $TASK\nBegin: $BEGIN"

