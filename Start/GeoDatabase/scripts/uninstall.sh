#!/bin/bash

SERVICE_NAMES=("geodb-update.timer" "geodb-update.service")
FILE_NAMES=("geosite.dat" "geoip.dat" "GeoLite2-Country.mmdb")
VERSION_FILE_NAMES=("geodb_version" "geolite_version")

for service_name in "${SERVICE_NAMES[@]}"; do
	systemctl stop "$service_name"
	systemctl disable "$service_name"
	rm -rf "/etc/systemd/system/$service_name"
	systemctl daemon-reload
done

for file_name in "${FILE_NAMES[@]}"; do
	rm -rf /opt/PX/core/$file_name
done

for version_file_name in "${VERSION_FILE_NAMES[@]}"; do
	rm -rf /opt/PX/info/$version_file_name
done
