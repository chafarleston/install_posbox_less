#!/usr/bin/env bash

PKGS_TO_INSTALL="adduser postgresql python3 python3-dateutil python3-decorator python3-docutils python3-feedparser python3-pil python3-jinja2 python3-ldap3 python3-lxml python3-mako python3-mock python3-openid python3-psutil python3-psycopg2 python3-babel python3-pydot python3-pyparsing python3-pypdf2 python3-reportlab python3-requests python3-simplejson python3-tz python3-vatnumber python3-werkzeug python3-yaml python3-serial python3-pip python3-dev vim mc mg screen hostapd git rsync python3-netifaces python3-passlib python3-libsass python3-qrcode python3-html2text python3-unittest2 python3-simplejson"
# KEEP OWN CONFIG FILES DURING PACKAGE CONFIGURATION
# http://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PKGS_TO_INSTALL}

pg_lsclusters
systemctl start postgresql@9.6-main
systemctl status postgresql@9.6-main

sudo -u postgres createuser -s pi

apt-get clean
localepurge
rm -rf /usr/share/doc

adduser pi --disabled-password --quiet --shell /sbin/nologin --gecos "pi"
echo 'pi:raspberry' | chpasswd
cd /home/pi
git clone -b 11.0 --no-checkout --depth 1 https://github.com/odoo/odoo.git 
cd odoo
git config core.sparsecheckout true
echo "addons/web
addons/hw_*
addons/point_of_sale/tools/posbox/configuration
odoo/
odoo-bin" | tee --append .git/info/sparse-checkout > /dev/null
git read-tree -mu HEAD


pip3 install pyusb==1.0.0b1
pip3 install evdev

groupadd usbusers
usermod -a -G usbusers pi
usermod -a -G lp pi
usermod -a -G input lightdm
mkdir /var/log/odoo
chown pi:pi /var/log/odoo
chown pi:pi -R /home/pi/odoo/

# logrotate is very picky when it comes to file permissions
chown -R root:root /etc/logrotate.d/
chmod -R 644 /etc/logrotate.d/
chown root:root /etc/logrotate.conf
chmod 644 /etc/logrotate.conf

echo 'SUBSYSTEM=="usb", GROUP="usbusers", MODE="0660"
SUBSYSTEMS=="usb", GROUP="usbusers", MODE="0660"' > /etc/udev/rules.d/99-usb.rules

echo '[Unit]
Description=Odoo PosBoxLess
After=network.target
[Service]
Type=simple
User=pi
Group=pi
ExecStart=/home/pi/odoo/odoo-bin --load=web,hw_proxy,hw_posbox_homepage,hw_posbox_upgrade,hw_scale,hw_scanner,hw_escpos,hw_printer_network
KillMode=mixed
[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/posboxless.service

systemctl enable posboxless.service
reboot
