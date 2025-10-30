#!/bin/echo PleaseSource

#
# Default colors
# Ideally, you would overwrite these
#
source "$MY_DIR/include/util/themecolor.sh"
FZFM_COLOR_BORDER="${FZFM_COLOR_BORDER:-$(c 15)}"
FZFM_COLOR_BORDER_LABEL="${FZFM_COLOR_BORDER_LABEL:-$(c 15)}"
FZFM_COLOR_HEADER="${FZFM_COLOR_HEADER:-$(c 15)}"
FZFM_COLOR_LIST_BORDER="${FZFM_COLOR_LIST_BORDER:-$(c 2)}"
FZFM_COLOR_LIST_LABEL="${FZFM_COLOR_LIST_LABEL:-$(c 10)}"
FZFM_COLOR_INPUT_BORDER="${FZFM_COLOR_INPUT_BORDER:-$(c 1)}"
FZFM_COLOR_INPUT_LABEL="${FZFM_COLOR_INPUT_LABEL:-$(c 1)}"
FZFM_COLOR_HEADER_BORDER="${FZFM_COLOR_HEADER_BORDER:-$(c 4)}"
FZFM_COLOR_HEADER_LABEL="${FZFM_COLOR_HEADER_LABEL:-$(c 12)}"

#
# Exported default flags
#
export FLAGS=(
    "--border --padding 1,2"
    "--border-label '$FZFM_BORDER_LABEL' " 
    "--input-label '$FZFM_INPUT_LABEL' " 
    "--header-label '$FZFM_HEADER_LABEL' " 
    "--bind 'focus:+transform-header:file -E --brief $FZFM_DIRECTORY/{} || echo no file selected'"
    "--bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' "
    "--color border:$FZFM_COLOR_BORDER,label:$FZFM_COLOR_BORDER_LABEL" 
    "--color list-border:$FZFM_COLOR_LIST_BORDER,list-label:$FZFM_COLOR_LIST_LABEL" 
    "--color input-border:$FZFM_COLOR_INPUT_BORDER,input-label:$FZFM_COLOR_INPUT_LABEL" 
    "--color header-border:$FZFM_COLOR_HEADER_BORDER,header-label:$FZFM_COLOR_HEADER_LABEL"
)

