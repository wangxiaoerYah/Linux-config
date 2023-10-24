#!/bin/bash

##### PreFunction Start #####
readonly BASE_URL="https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/latest/"
readonly LOG_ERROR="\e[31m%s\e[0m\n"
readonly LOG_INFO="\e[32m%s\e[0m\n"
readonly LOG_DEBUG="\e[33m%s\e[0m\n"
readonly LOG_WARN="\e[34m%s\e[0m\n"

function source_md5() {
	local download_url="${BASE_URL}allmd5.sh"
	readonly download_url
	local target_path="/tmp/allmd5.sh"
	readonly target_path
	local max_attempts=5
	readonly max_attempts
	local attempt=1
	while [ ${attempt} -le ${max_attempts} ]; do
		curl -H 'Cache-Control: no-cache' -s -o ${target_path} ${download_url}
		if [ $? -eq 0 ]; then
			source ${target_path}
			if [ ${?} -eq 0 ] && [ "$ALL_MD5_COMPLETE" = "true" ]; then
				printf ${LOG_INFO} "The md5file was downloaded successfully."
				main
				rm -rf ${target_path}
				exit 0
			fi
		fi
		echo ""
		printf ${LOG_ERROR} "Download md5file failed. Retrying in 3 seconds..."
		sleep 3
		((attempt++))
	done
	printf ${LOG_ERROR} "Failed to download the md5file after ${max_attempts} attempts."
	exit 1
}

function download_and_check() {
	if [ -z "${1}" ]; then
		printf ${LOG_ERROR} "Please provide a source_filename."
		exit 1
	fi
	if [ -z "${2}" ]; then
		printf ${LOG_ERROR} "Please provide a source_path."
		exit 1
	fi
	if [ -z "${3}" ]; then
		printf ${LOG_ERROR} "Please provide a target_path."
		exit 1
	fi
	local filename=${1}
	readonly filename
	local source_path=${2}
	readonly source_path
	local target_path=${3}
	readonly target_path
	local tmp_path="/tmp/${filename}"
	readonly tmp_path
	local download_url=${BASE_URL}${source_path}${filename}
	readonly download_url
	local check_name=$(echo "${filename}" | awk '{gsub(/[^a-zA-Z0-9]/, "_"); if ($0 ~ /^[0-9]/) $0 = "file_"$0; print $0}')
	readonly check_name
	local md5_value=${!check_name}
	readonly md5_value
	local max_attempts=5
	readonly max_attempts
	local attempt=1
	while [ ${attempt} -le ${max_attempts} ]; do
		curl -H 'Cache-Control: no-cache' -s -o ${tmp_path} ${download_url}
		if [ ${?} -eq 0 ]; then
			if [ -n ${md5_value} ]; then
				printf ${LOG_DEBUG} "The MD5 value for ${filename} is ${md5_value}."
				local calculated_md5=$(md5sum ${tmp_path} | awk '{print $1}')
				if [ ${calculated_md5} == ${md5_value} ]; then
					printf ${LOG_INFO} "The ${filename} Downloaded and Validation successfully."
					mv ${tmp_path} ${target_path}
					return 0
				else
					printf ${LOG_ERROR} "The ${filename} Validation failed."
				fi
			else
				printf ${LOG_ERROR} "No MD5 value found for ${filename}."
				exit 1
			fi
		fi
		printf ${LOG_ERROR} "Download ${filename} failed. Retrying in 3 seconds..."
		sleep 3
		((attempt++))
	done
	printf ${LOG_ERROR} "Failed to download the ${filename} after ${max_attempts} attempts."
	exit 1
}
##### PreFunction End #####

function main() {

	if [ $(
		pacman -Qi btrfs-progs >/dev/null 2>&1
		echo $?
	) -eq 0 ]; then
		printf ${LOG_DEBUG} "The package btrfs-progs is installed"
	else
		pacman -S btrfs-progs --noconfirm
	fi

	##### Download Start #####
	# Kernel
	if [ $(uname -m) == "aarch64" ]; then
		download_and_check \
			"mkinitcpio-aarch64.conf" \
			"root/etc/" \
			"/etc/mkinitcpio.conf"
	fi

	if [ $(uname -m) == "x86_64" ]; then
		download_and_check \
			"mkinitcpio-x86_64.conf" \
			"root/etc/" \
			"/etc/mkinitcpio.conf"
	fi

	# File
	download_and_check \
		"locale.gen" \
		"root/etc/" \
		"/etc/locale.gen"

	download_and_check \
		"locale.conf" \
		"root/etc/" \
		"/etc/locale.conf"

	# systemd
	download_and_check \
		"journald.conf" \
		"root/etc/systemd/" \
		"/etc/systemd/journald.conf"

	download_and_check \
		"resolved.conf" \
		"root/etc/systemd/" \
		"/etc/systemd/resolved.conf"

	download_and_check \
		"timesyncd.conf" \
		"root/etc/systemd/" \
		"/etc/systemd/timesyncd.conf"

	# env
	## ssh
	mkdir -p /etc/ssh
	download_and_check \
		"sshd_config" \
		"root/etc/ssh/" \
		"/etc/ssh/sshd_config"

	## profile
	rm -rf /etc/profile.d
	mkdir -p /etc/profile.d
	download_and_check \
		"editor.sh" \
		"root/etc/profile.d/" \
		"/etc/profile.d/editor.sh"

	# other
	download_and_check \
		"sudoers" \
		"root/etc/" \
		"/etc/sudoers"

	# repo
	if [ $(uname -m) == "aarch64" ]; then
		download_and_check \
			"pacman-aarch64.conf" \
			"root/etc/" \
			"/etc/pacman.conf"

		download_and_check \
			"mirrorlist-aarch64" \
			"root/etc/pacman.d/" \
			"/etc/pacman.d/mirrorlist"
	fi

	if [ $(uname -m) == "x86_64" ]; then
		download_and_check \
			"pacman-x86_64.conf" \
			"root/etc/" \
			"/etc/pacman.conf"

		download_and_check \
			"mirrorlist-x86_64" \
			"root/etc/pacman.d/" \
			"/etc/pacman.d/mirrorlist"
	fi

	##### Download End #####
	##### Configure Start #####
	## profile
	for file in $(find /etc/profile.d/ -name "*.sh"); do
		chmod +x $file
	done

	### Service Start ###
	systemctl daemon-reload
	## Kernel
	mkinitcpio -P

	## resolved
	ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
	systemctl enable --now systemd-resolved.service
	## timesync
	systemctl enable --now systemd-timesyncd.service
	systemctl enable systemd-networkd-wait-online.service

	sleep 8s
	### Service End ###
	## configure
	locale-gen

	pacman -Scc --noconfirm
	pacman -Syy
	pacman -Syyu --noconfirm

	if [ $(
		pacman -Qi pacman-contrib >/dev/null 2>&1
		echo $?
	) -eq 0 ]; then
		printf ${LOG_DEBUG} "The package pacman-contrib is installed"
		systemctl enable paccache.timer
	else
		pacman -S pacman-contrib --noconfirm
		systemctl enable paccache.timer
	fi

	##### Configure End #####
}

##### Run Start #####
source_md5
##### Run End #####
