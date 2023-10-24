#! /bin/bash

rm -rf /opt/PX/info/hysteria_version
wget -q -O /etc/systemd/system/hysteria-update.timer https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/hysteria-update.timer
wget -q -O /etc/systemd/system/hysteria.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/hysteria.service
wget -q -O /etc/systemd/system/hysteria-update.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/hysteria-update.service
systemctl daemon-reload
systemctl enable hysteria-update.timer
systemctl enable hysteria.service
systemctl start hysteria-update.service
