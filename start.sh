#!/bin/bash

value=`cat url.txt`
chromium \
    --no-first-run \
    --start-maximized \
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
    $value
