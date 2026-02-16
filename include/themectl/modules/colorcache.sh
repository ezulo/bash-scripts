#!/bin/echo Please-Source

#
# themectl module: colorcache
# Generates a shell-sourceable color cache for fast color lookups.
# This eliminates repeated jq calls in scripts that need theme colors.
#

MOD="colorcache"
ID="$_ID:$MOD"

COLORCACHE_DIR="$XDG_CACHE_HOME/theme"
COLORCACHE_FILE="$COLORCACHE_DIR/colors.sh"

colorcache_theme() {
    local ID="$ID:${FUNCNAME[0]}"
    [ ! -f "$COLORS_JSON" ] && log_error "$ID" "colors.json not found" && return 1
    mkdir -p "$COLORCACHE_DIR"

    # Generate cache file with all colors as shell variables
    {
        echo "# Auto-generated color cache - do not edit"
        echo "# Source: $COLORS_JSON"
        echo "# Generated: $(date -Iseconds)"
        echo ""
        jq -r '
            (.colors | to_entries[] | "COLOR_\(.key)=\"\(.value)\""),
            (.special | to_entries[] | "COLOR_\(.key)=\"\(.value)\"")
        ' "$COLORS_JSON"
        echo ""
        echo "# Special color keys (for iteration)"
        printf 'COLORCACHE_SPECIAL_KEYS="%s"\n' "$(jq -r '.special | keys | join(" ")' "$COLORS_JSON")"
    } > "$COLORCACHE_FILE"

    log_debug "$ID" "Color cache written to $COLORCACHE_FILE"
}

colorcache_reload() {
    # No service to reload
    :
}

colorcache_clean() {
    [ -f "$COLORCACHE_FILE" ] && rm "$COLORCACHE_FILE"
}
