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
mkdir -p /home/kiosk/.config/openbox
mkdir -p /home/kiosk/chromeKiosk/
# get Start script
wget -O /home/kiosk/chromeKiosk/start.sh https://raw.githubusercontent.com/Mich21050/debianKiosk/main/start.sh
chmod +x /home/kiosk/chromeKiosk/start.sh

# create user if not exists
id -u kiosk &>/dev/null || useradd -m kiosk  -s /bin/bash 

# rights
chown -R kiosk /home/kiosk/

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
autologin-user=kiosk
user-session=openbox
EOF

# create default URL File
if [ -e "/home/kiosk/chromeKiosk/url.txt" ]; then
  mv /home/kiosk/chromeKiosk/url.txt /home/kiosk/chromeKiosk/url.txt.backup
fi
cat > /home/kiosk/chromeKiosk/url.txt << EOF
https://www.aventec.at/
EOF

# create autostart
if [ -e "/home/kiosk/.config/openbox/autostart" ]; then
  mv /home/kiosk/.config/openbox/autostart /home/kiosk/.config/openbox/autostart.backup
fi
cat > /home/kiosk/.config/openbox/autostart << EOF
#!/bin/bash

unclutter -idle 0.1 -grab -root &
source /home/kiosk/chromeKiosk/start.sh &
EOF

echo "Done!"
