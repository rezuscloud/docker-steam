#!/usr/bin/env bash

monitor_proton_dirs() {
    local LOCKFILE="/tmp/proton_monitor.lock"
    local SEARCH_DIR="$HOME/.steam/steam/steamapps/common"
    local SOURCE_FILE="/defaults/user_settings.py"
    if [ -f "$LOCKFILE" ]; then
        local PID=$(cat "$LOCKFILE")
        if kill -0 "$PID" > /dev/null 2>&1; then
            echo "Proton monitor is already running with PID $PID."
            return 0
        fi
    fi
    echo $$ > "$LOCKFILE"
    while true; do
        if [ -f "$SOURCE_FILE" ]; then
            shopt -s nullglob
            for dir in "$SEARCH_DIR"/*Proton*/; do
                if [ -d "$dir" ]; then
                    # Check if the destination file does NOT exist
                    if [ ! -f "$dir/user_settings.py" ]; then
                        echo "Copying settings to: $dir"
                        cp "$SOURCE_FILE" "$dir/"
                    fi
                fi
            done
            shopt -u nullglob
        fi
        sleep 1
    done
}

(monitor_proton_dirs) &

# Start DE
ulimit -c 0
export XCURSOR_THEME=breeze_cursors
export XCURSOR_SIZE=24
export XKB_DEFAULT_LAYOUT=us
export XKB_DEFAULT_RULES=evdev
# cage is a wlroots kiosk compositor. Unlike labwc it advertises
# zwlr_screencopy_manager_v1, which xdg-desktop-portal-wlr needs to capture
# frames for Steam Remote Play. cage runs a single app fullscreen; we run
# steam-kiosk, which starts the PipeWire/portal stack then launches Steam.
# WAYLAND_DISPLAY is left to cage's default (wayland-0).
export WAYLAND_DISPLAY=wayland-0
exec cage -- /usr/bin/steam-kiosk
