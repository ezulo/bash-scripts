#!/bin/echo PleaseSource

#
# Default colors
# Ideally, you would overwrite these
#
source "$MY_DIR/include/util/themecolor.sh"
COLOR_BORDER="${COLOR_BORDER:-$(c 15)}"
COLOR_BORDER_LABEL="${COLOR_BORDER_LABEL:-$(c 15)}"
COLOR_HEADER="${COLOR_HEADER:-$(c 15)}"
COLOR_LIST_BORDER="${COLOR_LIST_BORDER:-$(c 2)}"
COLOR_LIST_LABEL="${COLOR_LIST_LABEL:-$(c 10)}"
COLOR_INPUT_BORDER="${COLOR_INPUT_BORDER:-$(c 1)}"
COLOR_INPUT_LABEL="${COLOR_INPUT_LABEL:-$(c 1)}"
COLOR_HEADER_BORDER="${COLOR_HEADER_BORDER:-$(c 4)}"
COLOR_HEADER_LABEL="${COLOR_HEADER_LABEL:-$(c 12)}"

#
# Exported default flags
#
export FLAGS=(
    "--layout reverse"
    "--border --padding 1,2"
    "--border-label '$BORDER_LABEL' " 
    "--input-label '$INPUT_LABEL' " 
    "--header-label '$HEADER_LABEL' " 
    "--color border:$COLOR_BORDER,label:$COLOR_BORDER_LABEL" 
    "--color list-border:$COLOR_LIST_BORDER,list-label:$COLOR_LIST_LABEL" 
    "--color input-border:$COLOR_INPUT_BORDER,input-label:$COLOR_INPUT_LABEL" 
)

