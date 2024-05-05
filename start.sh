#!/bin/bash

unclutter -idle 0.1 -grab -root &

value=`cat /home/kiosk-user/chromeKiosk/url.txt`

if xrandr | grep -q "HDMI-1 connected"; then
    echo "External monitor detected on HDMI-1."

    # Disable the internal monitor (eDP-1)
    echo "Disabling internal monitor (eDP-1)..."
    xrandr --output eDP-1 --off

    # Set HDMI-1 as primary monitor
    echo "Setting HDMI-1 as primary monitor..."
    xrandr --output HDMI-1 --primary --auto
else
    echo "No external monitor detected on HDMI-1. Nothing to do."
fi

chromium \
    --no-first-run \
    --ignore-certificate-errors \
    --disable-restore-session-state \
    --start-maximized \
    --hide-scrollbars \
    --disable \
    --disable-translate \
    --disable-infobars \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --disable-session-crashed-bubble \
    --incognito \
    --kiosk \
    --remote-debugging-port=9222 \
    --remote-allow-origins=* \
    $value &
