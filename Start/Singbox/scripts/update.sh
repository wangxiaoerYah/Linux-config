#!/bin/bash

# Get latest version of Singbox
function get_latest_singbox_version() {
	wget -qO- -t1 -T2 "https://api.github.com/repos/SagerNet/sing-box/releases/latest" |
		grep "tag_name" |
		head -n 1 |
		awk -F ":" '{print $2}' |
		sed 's/\"//g;s/,//g;s/ //g'
}

# Get Singbox download URL
function get_singbox_download_url() {
	local singbox_version=$1
	local singbox_version_number=$(echo "$singbox_version" | sed 's/v//g')
	local arch=$(uname -m)
	if [ "$arch" == "aarch64" ]; then
		echo "https://github.com/SagerNet/sing-box/releases/download/${singbox_version}/sing-box-${singbox_version_number}-linux-arm64.tar.gz"
	else
		echo "https://github.com/SagerNet/sing-box/releases/download/${singbox_version}/sing-box-${singbox_version_number}-linux-amd64.tar.gz"
	fi
}

#  Check if tools are installed on Arch
function check_tools() {
	local tools=(wget tar)
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

# Check Singbox service exists
function check_services() {
	local service_name=(singbox.service singbox-update.service singbox-update.timer)
	for service_ in "${service_name[@]}"; do
		if [ ! -f "/etc/systemd/system/${service_}" ]; then
			echo "${service_} does not exist. Creating..."
			wget -q -O "/etc/systemd/system/${service_}" "${systemd_url}/${service_}"
			systemctl daemon-reload
			if [ "${service_}" != "singbox-update.service" ]; then
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

# Extract Singbox tar.gz file
function unzip_file() {
	tar -zxvf "$1" -C "$2"
}

# Download Singbox
function get_singbox() {
	local singbox_version=$1
	local singbox_download_url=$(get_singbox_download_url "$singbox_version")
	local singbox_version_number=$(echo "$singbox_version" | sed 's/v//g')
	local arch=$(uname -m)
	local file_path="${PX_HOME}/download/singbox.tar.gz"
	wget -q -O "$file_path" "$singbox_download_url"
	unzip_file "$file_path" "${PX_HOME}/download"
	if [ "$arch" == "aarch64" ]; then
		mv "${PX_HOME}/download/sing-box-${singbox_version_number}-linux-arm64" "${PX_HOME}/download/singbox"
	else
		mv "${PX_HOME}/download/sing-box-${singbox_version_number}-linux-amd64" "${PX_HOME}/download/singbox"
	fi
	chmod +x "${PX_HOME}/download/singbox/sing-box"
	mv "${PX_HOME}/download/singbox/sing-box" "${PX_HOME}/core/sing-box"
	rm -rf "${PX_HOME}/download/singbox"
	rm -rf "$file_path"
	chown APP:APP -R "${PX_HOME}"
}

# Check local Singbox is install
function check_singbox() {
	local singbox_version=$(cat "${PX_HOME}/info/singbox_version" 2>/dev/null || echo "")
	if [ -z "$singbox_version" ]; then
		echo "Singbox executable does not exist. Installing..."
		local latest_singbox_version=$(get_latest_singbox_version)
		get_singbox "$latest_singbox_version"
		echo "Version number: ${PX_HOME}/info/singbox_version does not exist. Creating..."
		echo "$latest_singbox_version" >"${PX_HOME}/info/singbox_version"
		systemctl start singbox.service
		echo "Singbox installed successfully."
	else
		echo "Singbox executable exists."
	fi
}

# Check version
function check_version() {
	local latest_singbox_version=$(get_latest_singbox_version)
	local singbox_version=$(cat "${PX_HOME}/info/singbox_version" 2>/dev/null || echo "")
	if [ -z "$singbox_version" ]; then
		echo "Version number: ${PX_HOME}/info/singbox_version does not exist. Creating..."
		echo "$latest_singbox_version" >"${PX_HOME}/info/singbox_version"
		get_singbox "$latest_singbox_version"
		systemctl start singbox.service
	elif [ "$singbox_version" != "$latest_singbox_version" ]; then
		echo "Local version number: $singbox_version is not equal to latest version number: $latest_singbox_version"
		echo "$latest_singbox_version" >"${PX_HOME}/info/singbox_version"
		get_singbox "$latest_singbox_version"
		systemctl restart singbox.service
	else
		echo "Local version number: $singbox_version is equal to latest version number: $latest_singbox_version"
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
	# Check Singbox executable
	check_singbox
	# Check version
	check_version
}

main
