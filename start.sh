#!/bin/bash

value=`cat url.txt`
chromium \
    --no-first-run \
    --ignore-certificate-errors \
    --disable-restore-session-state \
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
