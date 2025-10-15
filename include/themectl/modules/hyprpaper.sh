#!/bin/echo Please-Source

ID_HYPRPAPER="$_ID:hyprpaper"
HYPR_CONFIG_DIR="${HYPR_CONFIG_DIR:-$XDG_CONFIG_HOME/hypr}"
WALLPAPER_DIR="$THEME_HOME/$THEME/wallpapers"
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f 2> /dev/null | shuf)

_is_active() {
    ! command -v hyprpaper > /dev/null && return 1
    [ -z "$WALLPAPERS" ] || [ ! -d "$WALLPAPER_DIR" ] &&
        pgrep -f hyprpaper > /dev/null && killall hyprpaper > /dev/null && return 1
    return 0
}

_monitors() {
	echo $(hyprctl monitors -j | jq -r -r '.[] | .name')
}

hyprpaper_theme() {
    local ID="$ID_HYPRPAPER:theme"
    ! _is_active && return 0
    # Ignore if command does not exist
    MONITORS=($(_monitors))
	echo -n "" > "$HYPR_CONFIG_DIR/hyprpaper.conf"
    i=1
	for MONITOR in "${MONITORS[@]}"; do
		WALLPAPER=$(echo "$WALLPAPERS"| head -n $i | tail -n 1)
		echo "preload = $WALLPAPER" >> "$HYPR_CONFIG_DIR/hyprpaper.conf"
		echo "wallpaper = $MONITOR, $WALLPAPER" >> \
            "$HYPR_CONFIG_DIR/hyprpaper.conf"
        i=$(($i+1))
	done
}

hyprpaper_reload() {
    local ID="$ID_HYPRPAPER:reload"
    ! _is_active && return 0
    # Kill hyprpaper if there are no wallpapers
    # Start hyprpaper if it isn't running
    ! pgrep -f hyprpaper > /dev/null && hyprpaper > /dev/null 2>&1 &
    MONITORS=($(_monitors))
    i=1
    for MONITOR in "${MONITORS[@]}"; do
		WALLPAPER=$(echo "$WALLPAPERS"| head -n $i | tail -n 1)
        hyprctl hyprpaper reload "$MONITOR","$WALLPAPER" &> /dev/null 2>&1
        i=$(($i+1))
    done
}

hyprpaper_clean() {
    ID="$ID_HYPRPAPER:clean"
    log_trace "$ID" "Nothing done."
}

