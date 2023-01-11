#! /bin/bash

wget -q -O /etc/systemd/system/xray-update.timer https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/xray-update.timer
wget -q -O /etc/systemd/system/xray.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/xray.service
wget -q -O /etc/systemd/system/xray-update.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/xray-update.service
systemctl daemon-reload
systemctl enable xray-update.timer
systemctl enable xray.service
systemctl enable --now xray-update.service
journalctl -xeu xray-update.service -f
