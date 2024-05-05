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

apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
# dir
mkdir -p /home/kiosk-user/.config/openbox
mkdir -p /home/kiosk-user/chromeKiosk/
# get Start script

# create user if not exists
id -u kiosk-user &>/dev/null || sudo useradd -m kiosk-user  -s /bin/bash 

# rights
chown -R kiosk-user /home/kiosk-user/

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
cat << EOF >> /etc/systemd/logind.conf
[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
EOF

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

wget -O /home/kiosk-user/getimage.sh https://raw.githubusercontent.com/Mich21050/debianKiosk/main/getimage.sh
chmod +x /home/kiosk-user/getimage.sh

# docker run -d --network=host --restart=always -v /home/kiosk-user/chromeKiosk:/code/config --name=chromeKiosk mich21050/chromekiosk
if [ -e "/etc/systemd/system/docker.chromekiosk.service" ]; then
  mv /etc/systemd/system/docker.chromekiosk.service /etc/systemd/system/docker.chromekiosk.service.backup
fi
cat > /etc/systemd/system/docker.chromekiosk.service << EOF
[Unit]
Description=ChromeKiosk Container
After=docker.service
Requires=docker.service
After=network-online.target
Requires=network-online.target

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=/home/kiosk-user/getimage.sh
ExecStartPre=-/usr/bin/docker exec %n stop
ExecStartPre=-/usr/bin/docker rm %n
ExecStart=/usr/bin/docker run --rm --name %n \
        --network=host \
        -v /home/kiosk-user/chromeKiosk:/code/config \
        mich21050/chromekiosk

[Install]
WantedBy=default.target
EOF

# ln -s /etc/systemd/system/docker.chromekiosk.service /etc/systemd/system/default.target.wants/docker.chromekiosk.service 
systemctl enable docker.chromekiosk
echo "Done!"
