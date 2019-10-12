
#!/usr/bin/env bash

PKGS_TO_INSTALL="cups adduser postgresql-client python python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-babel python-pychart python-pydot python-pyparsing python-pypdf2 python-reportlab python-requests python-tz python-vatnumber python-vobject python-werkzeug python-xlwt python-yaml postgresql python-gevent python-serial python-pip python-dev localepurge vim mc mg screen iw hostapd isc-dhcp-server git rsync console-data"
apt-get -y install ${PKGS_TO_INSTALL}

adduser -m pi -s /sbin/nologin -p 'raspberry'
cd /home/pi
git clone -b 9.0 --no-checkout --depth 1 https://github.com/odoo/odoo.git 
cd odoo
git config core.sparsecheckout true
echo "addons/web
addons/web_kanban
addons/hw_*
addons/point_of_sale/tools/posbox/configuration
openerp/
odoo.py" | tee --append .git/info/sparse-checkout > /dev/null
git read-tree -mu HEAD


pip install pyserial pyusb==1.0.0b1 qrcode evdev babel pypdf

groupadd usbusers
usermod -a -G usbusers pi
usermod -a -G lp pi
usermod -a -G lpadmin pi 

sudo -u postgres createuser -s pi
mkdir /var/log/odoo
chown pi:pi /var/log/odoo

echo 'SUBSYSTEM=="usb", GROUP="usbusers", MODE="0660"
SUBSYSTEMS=="usb", GROUP="usbusers", MODE="0660"' > /etc/udev/rules.d/99-usbusers.rules

echo '[Unit]
Description=Odoo PosBoxLess
After=network.target

[Service]
Type=simple
User=pi
Group=pi
ExecStart=/home/pi/odoo/odoo.py --load=web,hw_proxy,hw_posbox_homepage,hw_posbox_upgrade,hw_scale,hw_scanner,hw_escpos,hw_blackbox_be,hw_screen,hw_printer_network
KillMode=mixed

[Install]
WantedBy=multi-user.target

' > /etc/systemd/system/posboxless.service

systemctl enable posboxless.service
reboot
