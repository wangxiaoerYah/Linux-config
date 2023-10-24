#!/bin/bash

# Get latest version of Hysteria-core
function get_latest_hysteria_version() {
	wget -qO- -t1 -T2 "https://api.github.com/repos/apernet/hysteria/releases" |
		grep "tag_name" |
		head -n 1 |
		awk -F ":" '{print $2}' |
		sed 's/\"//g;s/,//g;s/ //g'
}

# Get Hysteria-core download URL
function get_hysteria_download_url() {
	local hysteria_version=$1
	local arch=$(uname -m)
	if [ "$arch" == "aarch64" ]; then
		echo "https://github.com/apernet/hysteria/releases/download/${hysteria_version}/hysteria-linux-arm64"
	else
		echo "https://github.com/apernet/hysteria/releases/download/${hysteria_version}/hysteria-linux-amd64"
	fi
}

# Check if tools are installed on Arch
function check_tools() {
	local tools=(wget)
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

# Check Hysteria service exists
function check_services() {
	local service_name=(hysteria.service hysteria-update.service hysteria-update.timer)
	for service_ in "${service_name[@]}"; do
		if [ ! -f "/etc/systemd/system/${service_}" ]; then
			echo "${service_} does not exist. Creating..."
			wget -q -O "/etc/systemd/system/${service_}" "${systemd_url}/${service_}"
			systemctl daemon-reload
			if [ "${service_}" != "hysteria-update.service" ]; then
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

# Download Hysteria
function get_hysteria() {
	local hysteria_version=$1
	local github_download_url=$(get_hysteria_download_url "$hysteria_version")
	local file_path="${PX_HOME}/download/hysteria-${hysteria_version}"
	wget -q -O "$file_path" "$github_download_url"
	chmod +x "${PX_HOME}/download/hysteria-${hysteria_version}"
	mv "${PX_HOME}/download/hysteria-${hysteria_version}" "${PX_HOME}/core/hysteria"
	chown APP:APP -R "${PX_HOME}"
}

# Check local Hysteria is installed
function check_hysteria() {
	local hysteria_version=$(cat "${PX_HOME}/info/hysteria_version" 2>/dev/null || echo "")
	if [ -z "$hysteria_version" ]; then
		echo "Hysteria executable does not exist. Installing..."
		local latest_hysteria_version=$(get_latest_hysteria_version)
		get_hysteria "$latest_hysteria_version"
		echo "Version number: ${PX_HOME}/info/hysteria_version does not exist. Creating..."
		echo "$latest_hysteria_version" >"${PX_HOME}/info/hysteria_version"
		systemctl start hysteria.service
		echo "Hysteria installed successfully."
	else
		echo "Hysteria executable exists."
	fi
}

# Check version
function check_version() {
	local latest_hysteria_version=$(get_latest_hysteria_version)
	local hysteria_version=$(cat "${PX_HOME}/info/hysteria_version" 2>/dev/null || echo "")
	if [ -z "$hysteria_version" ]; then
		echo "Version number: ${PX_HOME}/info/hysteria_version does not exist. Creating..."
		echo "$latest_hysteria_version" >"${PX_HOME}/info/hysteria_version"
		get_hysteria "$latest_hysteria_version"
		systemctl start hysteria.service
	elif [ "$hysteria_version" != "$latest_hysteria_version" ]; then
		echo "Local version number: $hysteria_version is not equal to latest version number: $latest_hysteria_version"
		echo "$latest_hysteria_version" >"${PX_HOME}/info/hysteria_version"
		get_hysteria "$latest_hysteria_version"
		systemctl restart hysteria.service
	else
		echo "Local version number: $hysteria_version is equal to latest version number: $latest_hysteria_version"
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
	check_hysteria
	# Check version
	check_version
}

main
