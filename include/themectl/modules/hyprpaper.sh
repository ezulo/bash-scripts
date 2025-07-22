#!/bin/echo Please-Source

ID_HYPRPAPER="$_ID:hyprpaper"

hyprpaper_theme() {
    local ID="$ID_HYPRPAPER:theme"
    log_trace $ID "Nothing done."
}

hyprpaper_reload() {
    local ID="$ID_HYPRPAPER:reload"
    # Ignore if command does not exist
    ! command -v hyprpaper > /dev/null && 
        log_warn $ID "hyprpaper command not found." && return 1
    WALLPAPER_DIR="$THEME_HOME/$THEME/wallpapers"
    WALLPAPERS=$(find "$WALLPAPER_DIR" -type f | shuf)
    if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$WALLPAPERS" ]; then
        pgrep -f hyprpaper > /dev/null && killall hyprpaper
        return 0
    fi
    if ! pgrep -f hyprpaper > /dev/null; then
        hyprpaper > /dev/null 2>&1 &
    fi
	MONITORS=$(hyprctl monitors -j | jq -r -r '.[] | .name')
	echo -n "" > "$HYPR_CONFIG_DIR/hyprpaper.conf"
    i=1
	for MONITOR in $MONITORS; do
		WALLPAPER=$(echo "$WALLPAPERS"| head -n $i | tail -n 1)
		echo "preload = $WALLPAPER" >> "$HYPR_CONFIG_DIR/hyprpaper.conf"
		echo "wallpaper = $MONITOR, $WALLPAPER" >> \
            "$HYPR_CONFIG_DIR/hyprpaper.conf"
		hyprctl hyprpaper reload "$MONITOR","$WALLPAPER" &> /dev/null 2>&1
        sleep 0.2 # Sometimes hyprpaper has a hard time keeping up.
        i=$(($i+1))
	done
}

hyprpaper_clean() {
    ID="$ID_HYPRPAPER:clean"
    log_trace "$ID" "Nothing done."
}

