#!/bin/bash

# be new
apt-get update

# get software
apt-get install \
	unclutter \
    xorg \
    chromium \
    openbox \
    lightdm \
    locales \
    -y

# dir
mkdir -p /home/kiosk-user/.config/openbox
mkdir -p /home/kiosk-user/chromeKiosk/
# get Start script

# create user if not exists
id -u kiosk-user &>/dev/null || useradd -m kiosk-user  -s /bin/bash 

# rights
chown -R kiosk-user /home/kiosk-user/

# remove virtual consoles
# if [ -e "/etc/X11/xorg.conf" ]; then
#   mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
# fi
# cat > /etc/X11/xorg.conf << EOF
# Section "ServerFlags"
#     Option "DontVTSwitch" "true"
# EndSection
# EOF

# create config
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=kiosk-user
user-session=openbox
EOF

# create default URL File
if [ -e "/home/kiosk-user/chromeKiosk/url.txt" ]; then
  mv /home/kiosk-user/chromeKiosk/url.txt /home/kiosk-user/chromeKiosk/url.txt.backup
fi
cat > /home/kiosk-user/chromeKiosk/url.txt << EOF
https://www.aventec.at/
EOF

# create autostart
if [ -e "/home/kiosk-user/.config/openbox/autostart" ]; then
  mv /home/kiosk-user/.config/openbox/autostart /home/kiosk-user/.config/openbox/autostart.backup
fi
wget -O /home/kiosk-user/.config/openbox/autostart https://raw.githubusercontent.com/Mich21050/debianKiosk/main/start.sh
chown -R kiosk-user /home/kiosk-user/

# cat > /home/kiosk-user/.config/openbox/autostart << EOF
# #!/bin/bash

# unclutter -idle 0.1 -grab -root &

# value=`cat /home/kiosk-user/chromeKiosk/url.txt`

# chromium \
#     --no-first-run \
#     --ignore-certificate-errors \
#     --disable-restore-session-state \
#     --start-maximized \
#     --disable \
#     --disable-translate \
#     --disable-infobars \
#     --disable-suggestions-service \
#     --disable-save-password-bubble \
#     --disable-session-crashed-bubble \
#     --incognito \
#     --kiosk \
#     --remote-debugging-port=9222 \
#     --remote-allow-origins=* \
#     $value
# EOF

echo "Done!"
