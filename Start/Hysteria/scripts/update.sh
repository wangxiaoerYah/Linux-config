#! /bin/bash

# Hysteria-core最新版本号
gtihub_hysteria_version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/apernet/hysteria/releases" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'
)
# Hysteria-core下载链接
if [ $(uname -m) == "aarch64" ]; then
    github_download_url="https://github.com/apernet/hysteria/releases/download/${gtihub_hysteria_version}/hysteria-linux-arm64"
else
    github_download_url="https://github.com/apernet/hysteria/releases/download/${gtihub_hysteria_version}/hysteria-linux-amd64"
fi

# MaxMind IP 库
# GeoLite最新版本号
gtihub_geolite_version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/P3TERX/GeoLite.mmdb/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'
)
geolite_download_url="https://github.com/P3TERX/GeoLite.mmdb/releases/download/${gtihub_geolite_version}/GeoLite2-Country.mmdb"
# Systemd URL
systemd_url="https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system"



# Arch检查是否安装工具(unzip,wget)
function arch_check_tool(){
    # 检查wget
    if [ ! -f "/usr/bin/wget" ]; then
        echo "wget: /usr/bin/wget 不存在 安装"
        pacman -S wget --noconfirm
        echo "wget: /usr/bin/wget 安装成功"
    else
        echo "wget: /usr/bin/wget 存在"
    fi
}

# 检查路径
function Check_dir(){
    dir_name=(conf core download ssl info)
    if [ ! -d "/opt/PX" ]; then
        echo "PX_HOME: /opt/PX 不存在 创建"
        mkdir -p /opt/PX
        echo "PX_HOME创建成功"
        for dir_ in ${dir_name[@]}
        do
            echo "没有找到路径: /opt/PX/${dir_} 创建"
            mkdir -p /opt/PX/${dir_}
        done
    else
        echo "PX_HOME: /opt/PX 存在"
        for dir_ in ${dir_name[@]}
        do
            if [ ! -d "/opt/PX/${dir_}" ]; then
                echo "没有找到路径: /opt/PX/${dir_} 创建"
                mkdir -p /opt/PX/${dir_}
            else
                echo "路径/opt/PX/${dir_} 存在"
            fi
        done
    fi
    # PX HOME
    PX_HOME="/opt/PX"
}

# 判断Hysteria service是否存在
function If_Service(){
    service_name=(hysteria.service hysteria-update.service hysteria-update.timer)
    for service_ in ${service_name[@]}
    do
        if [ ! -f "/etc/systemd/system/${service_}" ]; then
            echo "${service_} 不存在 创建"
            wget -q -O /etc/systemd/system/${service_} ${systemd_url}/${service_}
            systemctl daemon-reload
            systemctl enable ${service_}
        else
            echo "${service_} 存在"
        fi
    done
}

# 下载Hysteria
function Get_Hysteria(){
    File_Path="${PX_HOME}/download/hysteria-${gtihub_hysteria_version}"
    wget -q -O ${File_Path} ${github_download_url}
    chmod +x ${PX_HOME}/download/hysteria-${gtihub_hysteria_version}
    mv ${PX_HOME}/download/hysteria-${gtihub_hysteria_version} ${PX_HOME}/core/hysteria
    # # MaxMind IP 库
    wget -q -O ${PX_HOME}/core/GeoLite2-Country.mmdb ${geolite_download_url}
    chown http:http -R ${PX_HOME}
}

# 检查本地Hysteria是否安装
function If_Hysteria(){
    if [ ! -f "${PX_HOME}/core/hysteria" ]; then
        echo "Hysteria执行文件 不存在 安装"
        Get_Hysteria
        echo "版本号: ${PX_HOME}/info/hysteria_version 不存在 创建"
        echo "${gtihub_hysteria_version}" > ${PX_HOME}/info/hysteria_version
        systemctl start hysteria.service
        echo "Hysteria 安装成功"
    else
        echo "Hysteria执行文件 存在"
    fi
}

#判断版本号
function If_Version(){
    if [ ! -f "${PX_HOME}/info/hysteria_version" ]; then
        echo "版本号: ${PX_HOME}/info/hysteria_version 不存在 创建"
        echo "${gtihub_hysteria_version}" > ${PX_HOME}/info/hysteria_version
        echo "版本号: ${PX_HOME}/info/geolite_version 不存在 创建"
        echo "${gtihub_geolite_version}" > ${PX_HOME}/info/geolite_version
        Get_Hysteria
        systemctl start hysteria.service
    else
        local hysteria_version=$(cat ${PX_HOME}/info/hysteria_version)
        if [ "${hysteria_version}" != "${gtihub_hysteria_version}" ]; then
            echo "本地版本号: ${hysteria_version} 不等于 最新版本号: ${gtihub_hysteria_version}"
            echo "${gtihub_hysteria_version}" > ${PX_HOME}/info/hysteria_version
            Get_Hysteria
            systemctl restart hysteria.service
        else
            echo "本地版本号: ${hysteria_version} 等于 最新版本号: ${gtihub_hysteria_version}"
        fi
        if [ ! -f "${PX_HOME}/info/geolite_version" ]; then
            echo "版本号: ${PX_HOME}/info/geolite_version 不存在 创建"
            echo "${gtihub_geolite_version}" > ${PX_HOME}/info/geolite_version
        fi
        local geolite_version=$(cat ${PX_HOME}/info/geolite_version)
        if [ "${geolite_version}" != "${gtihub_geolite_version}" ]; then
            echo "本地版本号: ${geolite_version} 不等于 最新版本号: ${gtihub_geolite_version}"
            echo "${gtihub_geolite_version}" > ${PX_HOME}/info/geolite_version
            # Route File
            wget -q -O ${PX_HOME}/core/GeoLite2-Country.mmdb ${geolite_download_url}
            chown http:http -R ${PX_HOME}
            systemctl restart hysteria.service
        else
            echo "本地版本号: ${geolite_version} 等于 最新版本号: ${gtihub_geolite_version}"
        fi
    fi
}

function main(){
    # Arch
    echo "当前为ArchLinux"
    # 检查工具安装
    arch_check_tool
    # 检查路径
    Check_dir
    # 检查Service
    If_Service
    # 检查Hysteria执行文件
    If_Hysteria
    # 检查版本
    If_Version
}

main


