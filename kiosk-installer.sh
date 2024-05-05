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

cat > /home/kiosk-user/getimage.sh << EOF
#!/bin/bash

# Set the name of the Docker image
image_name="mich21050/chromekiosk"

# Set the number of retries
num_retries=10

# Function to check if the Docker image exists
image_exists() {
    docker image inspect "$image_name" &> /dev/null
}

# Function to pull the Docker image
pull_image() {
    echo "Pulling Docker image: $image_name"
    docker pull "$image_name"
}

# Main loop to check if the image exists and pull if necessary
for (( i=1; i<=$num_retries; i++ )); do
    if image_exists; then
        echo "Docker image $image_name exists."
        break
    else
        echo "Docker image $image_name not found. Attempt $i of $num_retries"
        if [ $i -eq $num_retries ]; then
            echo "Max retries reached. Exiting..."
            exit 1
        fi
        pull_image
    fi
done
EOF
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
