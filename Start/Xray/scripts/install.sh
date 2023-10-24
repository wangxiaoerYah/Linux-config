#! /bin/bash

rm -rf /opt/PX/info/xray_version
wget -q -O /etc/systemd/system/xray-update.timer https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/xray-update.timer
wget -q -O /etc/systemd/system/xray.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/xray.service
wget -q -O /etc/systemd/system/xray-update.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/xray-update.service
systemctl daemon-reload
systemctl enable xray-update.timer
systemctl enable xray.service
systemctl start xray-update.service
