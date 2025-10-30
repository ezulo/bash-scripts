#!/bin/echo Please-Source

# pulls color values out of the current theme's `colors.json` and prints them (prettily)

# source guard
! [ -z "$UTIL_COLOR__SOURCED" ] && return 0
export UTIL_COLOR__SOURCED=1

# Luminance Delta Threshold (0 through 255) (default: 70)
# When the background and color are too similar, we color the output background 
# instead of the foreground. Decrease this to make this effect more sensitive.
L_DELTA_THRESHOLD=70

# Space between pretty print inline members
INLINE_PADDING=5

NO_COLOR=
NO_FMT=
NO_KEY=
[ ! command -v bc > /dev/null 2>&1 ] && NO_COLOR=true

# Error codes
export THEMECOLOR_INVALID_QUERY_ERR=3
export THEMECOLOR_REGEX_ERR=4
export THEMECOLOR_JSON_NOT_FOUND_ERR=5

# Pull theme data
THEME_HOME=${THEME_HOME:-"$XDG_CONFIG_HOME/theme"}
THEME="$(cat $THEME_HOME/current-theme)"
COLORS_JSON="$THEME_HOME/$THEME/colors.json"

# Helper function to calculate perceived luminance, used for colorizing output
rgb_luminance() {
    local EQ="0.2126 * $1 + 0.7152 * $2 + 0.0722 * $3"
    local L=$(echo "$EQ" | bc);
    printf "%.0f" "$L"
}

# Colorizes color hex (#000000 to #ffffff)
colorize_hex() {
    local HEX=$1 #e.g. "#012345"
    local HEX_REGEX='#[0-9|a-f|A-F]+$'
    [[ ! $HEX =~ $HEX_REGEX ]] || [ $(echo "$HEX" | wc -L) -ne 7 ] &&
        echo -ne "${HEX}[INVALID]" && exit $EXIT_CODE_REGEX_ERR
    local R=$((16#"${HEX:1:2}"))
    local G=$((16#"${HEX:3:2}"))
    local B=$((16#"${HEX:5:2}"))
    local L=$(rgb_luminance $R $G $B)
    local BG_L=$(bg_luminance)
    local L_DELTA=$(echo "$BG_L - $L" | bc)
    local COL_FG="\\033[38;2"
    local COL_BG="\\033[48;2"
    local COL_SEQ="${COL_FG};${R};${G};${B}m"
    local COL_CLEAR='\033[0m'
    [ ${L_DELTA#-} -lt $L_DELTA_THRESHOLD ] &&
        COL_SEQ="${COL_BG};${R};${G};${B}m"
    echo -n "${COL_SEQ}${HEX}${COL_CLEAR}"
}

# Gets hex code from colors.json based on query
get_color_hex() {
    local ID="$ID_COLOR:$FUNCNAME"
    local QUERY=$1
    case $QUERY in
        color*)
            local COLOR_CODE=$(echo "${QUERY#*color}")
            [ $COLOR_CODE -gt 15 ] || [ $COLOR_CODE -lt 0 ] && exit $EXIT_CODE_INVALID_QUERY
            COLOR=$(jq -r .[\"colors\"].$QUERY $COLORS_JSON)
            ;;
        *)
            COLOR=$(jq -r .[\"special\"].$QUERY $COLORS_JSON)
            [ "$COLOR" = "null" ] && exit $EXIT_CODE_INVALID_QUERY
            ;;
    esac
    printf "%b" "$COLOR"
}

# Prints colorized output (or non-colorized, if NO_COLOR is set)
print_color() {
    QUERY=$1
    KEY=$2
    NEWLINE=$3
    [ -z "$KEY" ] && KEY="$QUERY"
    COLOR_HEX=$(get_color_hex $1)
    [ -z $NO_COLOR ] && COLOR_HEX=$(colorize_hex "$COLOR_HEX")
    [ ! -z $NO_FMT ] && [ ! -z $NO_KEY ] && KEY="" || KEY="$KEY:"
    [ ! -z $NO_FMT ] &&
        OUT=$(echo -n "${KEY}${COLOR_HEX}") ||
        OUT=$(echo -n "${KEY} ")"${COLOR_HEX}"
    [ ! -z $NEWLINE ] && OUT="$OUT\n"
    printf "%b" "$OUT"
}

# Calculates background luminance (uses color0 if background undefined)
bg_luminance() {
    BG_HEX=$(get_color_hex background || get_color_hex color0)
    BG_R=$((16#${BG_HEX:1:2}))
    BG_G=$((16#${BG_HEX:3:2}))
    BG_B=$((16#${BG_HEX:5:2}))
    printf "%b" "$(rgb_luminance $BG_R $BG_G $BG_B)"
}

string_width() {
    echo "$1" | sed 's/ //g' | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | wc -L
}

colors_max_width() {
    local COLORS=("$@")
    COLORS_MW=0
    for COLOR in "${COLORS[@]}"; do
        WIDTH=$(string_width "$COLOR")
        [ $WIDTH -gt $COLORS_MW ] && COLORS_MW=$WIDTH
    done
    echo $COLORS_MW
}

pretty_print_align_hex() {
    local COLOR=$(echo "$1" | sed 's/ //g')
    local MAX_W=$2
    local WIDTH=$(string_width "$COLOR")
    local PAD_W=$((MAX_W - WIDTH + 1))
    printf -v PADDING '%0.s-' $(seq 1 $PAD_W)
    local IFS=":" && read -ra COLOR_P <<< "$COLOR"
    printf '%s: %s %s' ${COLOR_P[0]} ${PADDING} ${COLOR_P[1]}
}

pretty_print_all() {
    local COLOR_COLUMNS="$1" && shift
    local COLORS=("$@")
    # Get max width
    local COLORS_MW=$(colors_max_width "${COLORS[@]}")
    local MAX_I=$((${#COLORS[@]} / $COLOR_COLUMNS))
    for i in $(eval echo {0..$((MAX_I - 1))}); do
        for j in $(eval echo {0..$(($COLOR_COLUMNS - 1))}); do
            local IDX=$((i + j * MAX_I))
            local COLOR="${COLORS[$IDX]}"
            local WIDTH=$(string_width "$COLOR")
            local SPACES=$(($((COLORS_MW - WIDTH)) + INLINE_PADDING))
            pretty_print_align_hex "$COLOR" "$COLORS_MW"
            printf '%*s' "$SPACES" ''
        done
        echo ""
    done
}

print_all() {
    local COLORS=("$@")
    for COLOR in "${COLORS[@]}"; do
        echo "$COLOR" | sed 's/ //g'
    done
}

themecolor_get() {
    local ID="$ID_COLOR:$FUNCNAME"
    [ -z "$COLORS_JSON" ] && exit $THEMECOLOR_JSON_NOT_FOUND_ERR;
    local QUERY=${1:-"all"} && shift
    for ARG in "$@"; do
        [ "$ARG" = "no_color" ] && NO_COLOR=true
        [ "$ARG" = "no_fmt"   ] && NO_FMT=true
        [ "$ARG" = "no_key"   ] && NO_KEY=true
    done
    [[ "$QUERY" =~ ^[0-9]+$ ]] && QUERY="color${QUERY}"
    local COLORS=()
    local COLORS_SPECIAL=()
    case "$QUERY" in
        "all")
            for i in {0..15}; do
                QUERY="color${i}"
                COLOR_OUT=$(print_color "$QUERY" "$QUERY" "")
                COLORS+=("$COLOR_OUT")
            done
            SPEC_KEYS=$(jq -r '.special | keys[]' "$COLORS_JSON")
            while IFS="\r" read QUERY; do
                local COLOR_OUT=$(print_color "$QUERY" "$QUERY" "")
                local COLORS_SPECIAL+=("$COLOR_OUT")
            done <<< $SPEC_KEYS
            ! [ -z "$NO_FMT" ] && 
                print_all "${COLORS[@]}" &&
                print_all "${COLORS_SPECIAL[@]}" &&
                return 0
            pretty_print_all 2 "${COLORS[@]}"
            pretty_print_all 1 "${COLORS_SPECIAL[@]}"
            ;;
        *)
            print_all "$(print_color $QUERY $QUERY '')"
            ;;
    esac
}

# Shorthand to get unformatted color string
c() { themecolor_get "$1" no_key no_fmt no_color; }

