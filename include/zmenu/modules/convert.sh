#!/bin/echo Please-Source

ID="$_ID:convert"

MENU_PROMPT_MAIN="Select a conversion"

unit_to_string() {
    case "$1" in
        "in") echo "inches" ;; "ft") echo "feet" ;;
        "yd") echo "yards" ;; "mm") echo "millimeters" ;;
        "cm") echo "centimeters" ;; "m") echo "meters" ;;
        *) return 1 ;;
    esac
}

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

#
# Conversion Functions
# 
OPTS=(in2ft in2mm mm2in)
in2ft() { printf "%b'%b\"\n"    $(bc <<< "$1 / 12") $(bc <<< "$1 % 12"); }
in2mm() { printf "%b\n"         $(bc <<< "$1 * 25.4"); }
mm2in() { divide_by_thousand    $(bc <<< "($1 * 1000) / 25.4"); }

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


