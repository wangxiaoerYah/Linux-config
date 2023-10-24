#!/bin/bash

# GeoDatabase service名称
SERVICE_NAMES=("geodb-update.timer" "geodb-update.service")

# GeoDatabase文件名称
FILE_NAMES=("geosite.dat" "geoip.dat" "GeoLite2-Country.mmdb" "geosite.db" "geoip.db")

# GeoDatabase安装路径
PX_HOME="/opt/PX"

# Systemd service文件下载链接
SYSTEMD_URL="https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system"

# MY SERVERS
MY_SERVERS=(xray.service hysteria.service singbox.service)

# 获取GeoDatabase版本信息API链接
function get_geodatabase_api_url() {
	local file_name=${1}
	local github_api_url_1="https://api.github.com/repos/"
	local github_api_url_2="/releases/latest"
	case $file_name in
	"geosite.dat" | "geoip.dat")
		repo="Loyalsoldier/v2ray-rules-dat"
		api_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	"GeoLite2-Country.mmdb")
		repo="P3TERX/GeoLite.mmdb"
		api_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	"geosite.db")
		repo="SagerNet/sing-geosite"
		api_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	"geoip.db")
		repo="SagerNet/sing-geoip"
		api_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	esac
	echo ${api_url}
}

# 获取GeoDatabase文件下载链接
function get_geodatabase_download_url() {
	local file_name=${1}
	local github_api_url_1="https://github.com/"
	local github_api_url_2="/releases/download"
	case $file_name in
	"geosite.dat" | "geoip.dat")
		repo="Loyalsoldier/v2ray-rules-dat"
		download_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	"GeoLite2-Country.mmdb")
		repo="P3TERX/GeoLite.mmdb"
		download_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	"geosite.db")
		repo="SagerNet/sing-geosite"
		download_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	"geoip.db")
		repo="SagerNet/sing-geoip"
		download_url=${github_api_url_1}${repo}${github_api_url_2}
		;;
	esac
	echo ${download_url}
}

# 获取GeoDatabase版本信息文件名称
function get_geodatabase_version_file() {
	local file_name=${1}
	case $file_name in
	"geosite.dat")
		version_name="geodat_site_version"
		;;
	"geoip.dat")
		version_name="geodat_ip_version"
		;;
	"GeoLite2-Country.mmdb")
		version_name="geolite_version"
		;;
	"geosite.db")
		version_name="geodb_site_version"
		;;
	"geoip.db")
		version_name="geodb_ip_version"
		;;
	esac
	echo ${version_name}
}

# 获取最新版本号
function get_latest_version() {
	local file_name=${1}
	local api_url=$(get_geodatabase_api_url ${file_name})
	local version=$(wget -qO- -t1 -T2 ${api_url} | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
	if [ -z ${version} ]; then
		echo "获取最新版本号失败:" ${api_url}
		exit 1
	fi
	echo ${version}
}

# 检查路径
function check_dir() {
	local dir_names=("conf" "core" "download" "ssl" "info")
	if [ ! -d ${PX_HOME} ]; then
		echo "PX_HOME: "${PX_HOME}" 不存在，创建"
		mkdir -p ${PX_HOME}
		echo ${PX_HOME}"创建成功"
		for dir_name in ${dir_names[@]}; do
			echo "没有找到路径: "${PX_HOME}"/"${dir_name}" 创建"
			mkdir -p "${PX_HOME}/${dir_name}"
		done
	else
		echo "PX_HOME: "${PX_HOME}" 存在"
		for dir_name in ${dir_names[@]}; do
			if [ ! -d ${PX_HOME}"/"${dir_name} ]; then
				echo "没有找到路径: "${PX_HOME}"/"${dir_name}" 创建"
				mkdir -p "${PX_HOME}/${dir_name}"
			else
				echo "路径"${PX_HOME}"/"${dir_name}" 存在"
			fi
		done
	fi
}

# 下载文件
function download_file() {
	local url=${1}
	local file_path=${2}
	wget -q -O ${file_path} ${url}
	if [ $? -ne 0 ]; then
		echo "下载文件失败: "${url}
		exit 1
	fi
}

# 重启服务
function restart_service() {
	for my_server_name in ${MY_SERVERS[@]}; do
		if [ -f "/etc/systemd/system/"${my_server_name} ]; then
			systemctl restart ${my_server_name}
		fi
	done
}

# 获取GeoDatabase文件
function get_geodatabase_files() {
	local file_name=${1}
	local latest_version=${2}
	local local_version_file=${3}
	local download_url=$(get_geodatabase_download_url ${file_name})"/"${latest_version}"/"${file_name}
	local file_path=${PX_HOME}"/core/"${file_name}
	local version_file_path=${PX_HOME}"/info/"${local_version_file}
	download_file ${download_url} ${file_path}
	echo ${latest_version} >${PX_HOME}"/info/"${local_version_file}
	chown APP:APP -R ${PX_HOME}
	restart_service
}

# 检查版本号
function check_version() {
	for file_name in ${FILE_NAMES[@]}; do
		local local_version_file=$(get_geodatabase_version_file ${file_name})
		local version_file_path=${PX_HOME}"/info/"${local_version_file}
		local latest_version=$(get_latest_version ${file_name})
		if [ -f ${version_file_path} ]; then
			local local_version=$(cat ${version_file_path})
			if [ ${local_version} == ${latest_version} ]; then
				printf ${file_name}"的本地版本:"${local_version}"等于最新版本:"${latest_version}"\n"
			else
				printf ${file_name}"的本地版本:"${local_version}"不等于最新版本:"${latest_version}"\n"
				get_geodatabase_files ${file_name} ${latest_version} ${local_version_file}
			fi
		else
			printf ${file_name}"没有找到本地版本开始下载\n"
			get_geodatabase_files ${file_name} ${latest_version} ${local_version_file}
		fi
	done
}

# 安装GeoDatabase service
function install_service() {
	for service_name in ${SERVICE_NAMES[@]}; do
		local service_path="/etc/systemd/system/"${service_name}
		if [ ! -f ${service_path} ]; then
			echo ${service_name}" 不存在 创建"
			download_file ${SYSTEMD_URL}"/"${service_name} ${service_path}
			systemctl daemon-reload
			if [[ ${service_name} != "geodb-update.service" ]]; then
				systemctl enable --now ${service_name}
			fi
		else
			echo ${service_name}" 存在"
		fi
	done
}

function main() {
	check_dir
	install_service
	check_version
}

main
