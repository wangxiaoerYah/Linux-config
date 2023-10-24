#! /bin/bash

# Get latest version of Xray-core
function get_latest_xray_version() {
	wget -qO- -t1 -T2 "https://api.github.com/repos/XTLS/Xray-core/releases" |
		grep "tag_name" |
		head -n 1 |
		awk -F ":" '{print $2}' |
		sed 's/\"//g;s/,//g;s/ //g'
}

# Get Xray-core download URL
function get_xray_download_url() {
	local xray_version=$1
	local arch=$(uname -m)
	if [ "$arch" == "aarch64" ]; then
		echo "https://github.com/XTLS/Xray-core/releases/download/${xray_version}/Xray-linux-arm64-v8a.zip"
	else
		echo "https://github.com/XTLS/Xray-core/releases/download/${xray_version}/Xray-linux-64.zip"
	fi
}

#  Check if tools are installed on Arch
function check_tools() {
	local tools=(unzip wget curl)
	for tool in "${tools[@]}"; do
		if ! command -v "$tool" &>/dev/null; then
			echo "$tool does not exist. Installing..."
			pacman -S "$tool" --noconfirm
			echo "$tool installed successfully."
		else
			echo "$tool exists."
		fi
	done
}

# Check directories
function check_dirs() {
	local dir_name=(conf core download ssl info)
	if [ ! -d "/opt/PX" ]; then
		echo "PX_HOME: /opt/PX does not exist. Creating..."
		mkdir -p /opt/PX
		echo "PX_HOME created successfully."
		for dir_ in "${dir_name[@]}"; do
			echo "Path not found: /opt/PX/${dir_}. Creating..."
			mkdir -p "/opt/PX/${dir_}"
		done
	else
		echo "PX_HOME: /opt/PX exists."
		for dir_ in "${dir_name[@]}"; do
			if [ ! -d "/opt/PX/${dir_}" ]; then
				echo "Path not found: /opt/PX/${dir_}. Creating..."
				mkdir -p "/opt/PX/${dir_}"
			else
				echo "Path /opt/PX/${dir_} exists."
			fi
		done
	fi
	# PX HOME
	PX_HOME="/opt/PX"
}

# Check Xray service exists
function check_services() {
	local service_name=(xray.service xray-update.service xray-update.timer)
	for service_ in "${service_name[@]}"; do
		if [ ! -f "/etc/systemd/system/${service_}" ]; then
			echo "${service_} does not exist. Creating..."
			wget -q -O "/etc/systemd/system/${service_}" "${systemd_url}/${service_}"
			systemctl daemon-reload
			if [ "$service_" != " xray-update.service" ]; then
				systemctl enable --now "${service_}"
			fi
		else
			echo "${service_} exists."
		fi
	done
	local servers=(geodb-update.timer geodb-update.service)
	for server in "${servers[@]}"; do
		if [ ! -f "/etc/systemd/system/$server" ]; then
			echo "$server does not exist. Creating..."
			wget -q -O- https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/Start/GeoDatabase/scripts/install.sh | bash
			break
		else
			echo "$server exists."
		fi
	done
}

# Extract Xray-core zip file
function unzip_file() {
	unzip -o "$2" -d "$1"
}

# Download Xray-core
function get_xray() {
	local xray_version=$1
	local github_download_url=$(get_xray_download_url "$xray_version")
	local file_path="${PX_HOME}/download/xray-${xray_version}.zip"
	wget -q -O "$file_path" "$github_download_url"
	mkdir -p "${PX_HOME}/download/xray"
	unzip_file "${PX_HOME}/download/xray" "$file_path"
	mv "${PX_HOME}/download/xray/xray" "${PX_HOME}/core/xray"
	chmod +x "${PX_HOME}/core/xray"
	rm -rf "${PX_HOME}/download/*.zip"
	rm -rf "${PX_HOME}/download/xray"
	chown APP:APP -R "$PX_HOME"
}

# Check local Xray is installed
function check_xray() {
	local xray_version=$(cat "${PX_HOME}/info/xray_version" 2>/dev/null || echo "")
	if [ -z "$xray_version" ]; then
		echo "Xray executable does not exist. Installing..."
		local latest_xray_version=$(get_latest_xray_version)
		get_xray "$latest_xray_version"
		echo "Version number: ${PX_HOME}/info/xray_version does not exist. Creating..."
		echo "$latest_xray_version" >"${PX_HOME}/info/xray_version"
		systemctl start xray.service
		echo "Xray installed successfully."
	else
		echo "Xray executable exists."
	fi
}

# Check version
function check_version() {
	local latest_xray_version=$(get_latest_xray_version)
	local xray_version=$(cat "${PX_HOME}/info/xray_version" 2>/dev/null || echo "")
	if [ -z "$xray_version" ]; then
		echo "Version number: ${PX_HOME}/info/xray_version does not exist. Creating..."
		echo "$latest_xray_version" >"${PX_HOME}/info/xray_version"
		get_xray "$latest_xray_version"
		systemctl start xray.service
	elif [ "$xray_version" != "$latest_xray_version" ]; then
		echo "Local version number: $xray_version is not equal to latest version number: $latest_xray_version"
		echo "$latest_xray_version" >"${PX_HOME}/info/xray_version"
		get_xray "$latest_xray_version"
		systemctl restart xray.service
	else
		echo "Local version number: $xray_version is equal to latest version number: $latest_xray_version"
	fi
}

function main() {
	# Systemd URL
	local systemd_url="https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system"
	# Arch
	echo "Current OS: ArchLinux"
	# Check tool installation
	check_tools
	# Check directories
	check_dirs
	# Check service
	check_services
	# Check Xray executable
	check_xray
	# Check version
	check_version
}

main
