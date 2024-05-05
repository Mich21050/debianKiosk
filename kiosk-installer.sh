#!/bin/bash

# be new
apt-get update
apt-get upgrade

# get software
apt-get install \
	unclutter \
    xorg \
    chromium \
    openbox \
    lightdm \
    locales \
    wget \
    sudo \
    -y

wget -O - https://get.docker.com/ | bash
# dir
mkdir -p /home/kiosk-user/.config/openbox
mkdir -p /home/kiosk-user/chromeKiosk/
# get Start script

# create user if not exists
id -u kiosk-user &>/dev/null || sudo useradd -m kiosk-user  -s /bin/bash 

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

docker run -d --network=host --restart=always -v /home/kiosk-user/chromeKiosk:/code/config --name=chromeKiosk mich21050/chromekiosk
echo "Done!"
