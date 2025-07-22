#!/bin/echo Please-Source

ID_CSS="$_ID:util:css"

# Converts `colors.json` to css
colors_to_css() {
    local IFS='
    '
    local COLORS_JSON="$1"
    local OUT="$2"
    local NO_HEADER=
    [ "$3" == "no_header" ] && NO_HEADER=1
    local THEME_HOME=${THEME_HOME:-"$XDG_CONFIG_HOME/theme/$THEME"}
    PREFIX="@define-color " # Before color key
    DELIMITER=" " # After color key, before color value
    SUFFIX=";" # After color value
    [ "$2" == "rasi" ] &&
        PREFIX="\t" &&
        DELIMITER=":" &&
        SUFFIX=";"
    [ -z "$NO_HEADER" ] && write_file_header "$OUT" "$COLORS_JSON" "css"
    for idx in $(seq 0 15); do
        COLOR=$(jq -r .[\"colors\"].color$idx $COLORS_JSON)
        [ "$COLOR" != "null" ] &&
            echo -e "${PREFIX}color$idx${DELIMITER}${COLOR}${SUFFIX}" >> "$OUT"
    done
    SPEC_COLOR_KEYS=$(jq -r '.["special"] | keys[]' $COLORS_JSON)
    while read -r COLOR_KEY; do
        COLOR=$(jq -r ".[\"special\"].$COLOR_KEY" "$COLORS_JSON")
        CSS_KEY=$(echo "$COLOR_KEY" | sed -e 's/_/-/g')
        [ "$COLOR" != "null" ] &&
            echo -e "${PREFIX}color-${CSS_KEY}${DELIMITER}${COLOR}${SUFFIX}" >> "$OUT"
    done <<< $SPEC_COLOR_KEYS
    echo "" >> "$OUT"
}

