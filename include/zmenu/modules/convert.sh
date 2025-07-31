#!/bin/echo Please-Source

OPTS=()
for FILE in "$ZMENU_INCLUDE_DIR"/convert/*; do
    OPTS=( ${OPTS[@]} $(basename "$FILE" | sed -e 's/\.sh//g') )
done

MENU_PROMPT_MAIN="Select a conversion"

unit_to_string() {
    local UNIT="$1"
    case "$UNIT" in
        "in")
            echo "inches"
            ;;
        "ft")
            echo "feet"
            ;;
        "yd")
            echo "yards"
            ;;
        "mm")
            echo "millimeters"
            ;;
        "cm")
            echo "centimeters"
            ;;
        "m")
            echo "meters"
            ;;
        *)
            return 1
            ;;
    esac
}

opt_to_string() {
    local INPUT="$1"
    local DELIM=${2:-"2"}
    printf "%b%b%b" \
        $(unit_to_string $(cut -d "$DELIM" -f1 <<< "$INPUT")) \
        " to " \
        $(unit_to_string $(cut -d "$DELIM" -f2 <<< "$INPUT"))
}

MENU_OPTS=
for OPTS_I in "${OPTS[@]}"; do
    OPTS_I="$OPTS_I | $(opt_to_string $OPTS_I)"
    [ -z "$MENU_OPTS" ] && MENU_OPTS="$OPTS_I" && continue
    MENU_OPTS="$MENU_OPTS\n$OPTS_I"
done

MENU_OUT=$(d_read "$ID" "$MENU_OPTS" "$MENU_PROMPT_MAIN")
OPT=$(cut -d '|' -f1 <<< "$MENU_OUT" | xargs)
NUM_RE='^[+-]?[0-9]+([.][0-9]+)?$'

# "Pure bash" way to check if OPT is in the OPTS array (using for loop)
for OPTS_I in "${OPTS[@]}"; do
    case $OPT in
        $OPTS_I)
            echo "|$OPT|$OPTS_I|"
            FROM_UNIT_ABBREV=$(cut -d 2 -f1 <<< "$OPT")
            TO_UNIT_ABBREV=$(cut -d 2 -f2 <<< "$OPT")
            FROM_UNIT=$(unit_to_string "$FROM_UNIT_ABBREV")
            TO_UNIT=$(unit_to_string "$TO_UNIT_ABBREV")
            VAL=$( d_read_cached "$ID" "$OPT" "Enter $FROM_UNIT to convert to $TO_UNIT")
            ! [[ "$VAL" =~ $NUM_RE ]] &&
                log_error $ID "Not a number: $VAL" && exit 1
            source "$ZMENU_INCLUDE_DIR/convert/$OPT.sh"
            OUT=$($OPT "$VAL") && d_cache_append "$ID" "$OPT" "$VAL"
            echo -n $OUT | wl-copy
            # Append abbreviation; don't do it for feet (alrady has notation)
            [ "$TO_UNIT_ABBREV" != "ft" ] && OUT="$OUT $TO_UNIT_ABBREV"
            log_info "$ID" \
                "$VAL $FROM_UNIT to $TO_UNIT:\n$OUT\nCopied to clipboard."
            exit 0
            ;;
        *)
            continue
            ;;
    esac
done


