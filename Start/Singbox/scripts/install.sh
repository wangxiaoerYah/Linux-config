#!/bin/bash

rm -rf /opt/PX/info/singbox_version
wget -q -O /etc/systemd/system/singbox-update.timer https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/singbox-update.timer
wget -q -O /etc/systemd/system/singbox.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/singbox.service
wget -q -O /etc/systemd/system/singbox-update.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/singbox-update.service
systemctl daemon-reload
systemctl enable singbox-update.timer
systemctl enable singbox.service
systemctl start singbox-update.service
