#!/usr/bin/env bash
#
# Wayland session entrypoint (svc-de). The actual gamescope session is run by
# the supervised svc-gamescope s6 service (see root/etc/s6-overlay/s6-rc.d/
# svc-gamescope/run), which drives the real HDMI display and exposes a PipeWire
# capture stream for Steam Remote Play.
#
# This script is a no-op: it just blocks so svc-de (which waits for it) doesn't
# spin. gamescope owns the session. See svc-gamescope/run for the real work.

# Keep the proton-settings monitor (harmless, useful).
LOCKFILE="/tmp/proton_monitor.lock"
SEARCH_DIR="$HOME/.steam/steam/steamapps/common"
SOURCE_FILE="/defaults/user_settings.py"
monitor_proton_dirs() {
    echo $$ > "$LOCKFILE"
    while true; do
        if [ -f "$SOURCE_FILE" ]; then
            shopt -s nullglob
            for dir in "$SEARCH_DIR"/*Proton*/; do
                if [ -d "$dir" ] && [ ! -f "$dir/user_settings.py" ]; then
                    cp "$SOURCE_FILE" "$dir/"
                fi
            done
            shopt -u nullglob
        fi
        sleep 1
    done
}
(monitor_proton_dirs) &

# Block forever; the supervised svc-gamescope owns the desktop session.
exec sleep infinity
