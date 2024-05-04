#!/bin/bash

unclutter -idle 0.1 -grab -root &

value=`cat /home/kiosk-user/chromeKiosk/url.txt`

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
    $value &

docker run -d --network=host --restart=unless-stopped --name=chromeKiosk mich21050/chromekiosk &
