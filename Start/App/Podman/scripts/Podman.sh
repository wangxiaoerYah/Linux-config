#!/bin/bash

##### PreFunction Start #####
readonly BASE_URL="https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/refs/heads/latest/"
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
			if [ $? -eq 0 ] && [ "$ALL_MD5_COMPLETE" = "true" ]; then
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
		if [ $? -eq 0 ]; then
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

function d_fn_podman() {
	download_and_check \
		"containers.conf" \
		"root/etc/containers/" \
		"/etc/containers/containers.conf"

	download_and_check \
		"registries.conf" \
		"root/etc/containers/" \
		"/etc/containers/registries.conf"
}

function download_map() {
	local pkg_name=${1}
	case $pkg_name in
	"podman")
		d_fn_podman
		;;
	*)
		printf ${LOG_WARN} "Invalid option"
		;;
	esac
}

function main() {
	local check_packages=("podman")
	for c_pkg in ${check_packages[@]}; do
		if [ $(
			pacman -Qi ${c_pkg} >/dev/null 2>&1
			echo $?
		) -eq 0 ]; then
			printf ${LOG_DEBUG} "${c_pkg} install. Download hook."
			download_map ${c_pkg}
			systemctl daemon-reload
			systemctl enable podman-auto-update.service
		else
			printf ${LOG_DEBUG} "${c_pkg} not install."
		fi
	done
}

##### Run Start #####
source_md5
##### Run End #####
