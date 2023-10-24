#! /bin/bash

VERSION_FILE_NAMES=("geodb_version" "geolite_version")
VERSION_FILE_PATH="/opt/PX/info/"
for VERSION_FILE_NAME in ${VERSION_FILE_NAMES[@]}; do
	rm -rf ${VERSION_FILE_PATH}/${VERSION_FILE_NAME}
done
wget -q -O /etc/systemd/system/geodb-update.timer https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/geodb-update.timer
wget -q -O /etc/systemd/system/geodb-update.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/geodb-update.service

systemctl daemon-reload
systemctl enable geodb-update.timer
systemctl start geodb-update.service
