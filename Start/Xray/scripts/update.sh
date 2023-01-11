#! /bin/bash

# Xray-core最新版本号
gtihub_xray_version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/XTLS/Xray-core/releases" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'
)
# Xray-core下载链接
if [ $(uname -m) == "aarch64" ]; then
    github_download_url="https://github.com/XTLS/Xray-core/releases/download/${gtihub_xray_version}/Xray-linux-arm64-v8a.zip"
else
    github_download_url="https://github.com/XTLS/Xray-core/releases/download/${gtihub_xray_version}/Xray-linux-64.zip"
fi

# route最新版本号
gtihub_route_version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'
)
# geosite.dat下载链接
geosite_download_url="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${gtihub_route_version}/geosite.dat"
# geoip.dat下载链接
geoip_download_url="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${gtihub_route_version}/geoip.dat"
# Systemd URL
systemd_url="https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system"



# Arch检查是否安装工具(unzip,wget)
function arch_check_tool(){
    # 检查unzip
    if [ ! -f "/usr/bin/unzip" ]; then
        echo "unzip: /usr/bin/unzip 不存在 安装"
        pacman -S unzip --noconfirm
        echo "unzip: /usr/bin/unzip 安装成功"
    else
        echo "unzip: /usr/bin/unzip 存在"
    fi
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

# 判断Xray service是否存在
function If_Service(){
    service_name=(xray.service xray-update.service xray-update.timer)
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

# 解压Xray(强制覆盖)
function Un_File_zip(){
    unzip -o ${2} -d ${1}
}

# 下载Xray
function Get_Xray(){
    File_Path="${PX_HOME}/download/xray-${gtihub_xray_version}.zip"
    wget -q -O ${File_Path} ${github_download_url}
    Un_File_zip ${PX_HOME}/core ${File_Path}
    rm -rf ${PX_HOME}/download/*.zip
    # Route File
    wget -q -O ${PX_HOME}/core/geosite.dat ${geosite_download_url}
    wget -q -O ${PX_HOME}/core/geoip.dat ${geoip_download_url}
    chown http:http -R ${PX_HOME}
}

# 检查本地Xray是否安装
function If_Xray(){
    if [ ! -f "${PX_HOME}/core/xray" ]; then
        echo "Xray执行文件 不存在 安装"
        Get_Xray
        echo "版本号: ${PX_HOME}/info/xray_version 不存在 创建"
        echo "${gtihub_xray_version}" > ${PX_HOME}/info/xray_version
        systemctl start xray.service
        echo "Xray 安装成功"
    else
        echo "Xray执行文件 存在"
    fi
}

#判断版本号
function If_Version(){
    if [ ! -f "${PX_HOME}/info/xray_version" ]; then
        echo "版本号: ${PX_HOME}/info/xray_version 不存在 创建"
        echo "${gtihub_xray_version}" > ${PX_HOME}/info/xray_version
        echo "版本号: ${PX_HOME}/info/route_version 不存在 创建"
        echo "${gtihub_route_version}" > ${PX_HOME}/info/route_version
        Get_Xray
        systemctl start xray.service
    else
        local xray_version=$(cat ${PX_HOME}/info/xray_version)
        if [ "${xray_version}" != "${gtihub_xray_version}" ]; then
            echo "本地版本号: ${xray_version} 不等于 最新版本号: ${gtihub_xray_version}"
            echo "${gtihub_xray_version}" > ${PX_HOME}/info/xray_version
            Get_Xray
            systemctl restart xray.service
        else
            echo "本地版本号: ${xray_version} 等于 最新版本号: ${gtihub_xray_version}"
        fi
        if [ ! -f "${PX_HOME}/info/route_version" ]; then
            echo "版本号: ${PX_HOME}/info/route_version 不存在 创建"
            echo "${gtihub_route_version}" > ${PX_HOME}/info/route_version
        fi
        local route_version=$(cat ${PX_HOME}/info/route_version)
        if [ "${route_version}" != "${gtihub_route_version}" ]; then
            echo "本地版本号: ${route_version} 不等于 最新版本号: ${gtihub_route_version}"
            echo "${gtihub_route_version}" > ${PX_HOME}/info/route_version
            # Route File
            wget -q -O ${PX_HOME}/core/geosite.dat ${geosite_download_url}
            wget -q -O ${PX_HOME}/core/geoip.dat ${geoip_download_url}
            chown http:http -R ${PX_HOME}
            systemctl restart xray.service
        else
            echo "本地版本号: ${route_version} 等于 最新版本号: ${gtihub_route_version}"
        fi
    fi
}





# Debian检查是否安装工具(unzip,wget)
# function debian_check_tool(){
#     # 检查unzip
#     if [ ! -f "/usr/bin/unzip" ]; then
#         echo "unzip: /usr/bin/unzip 不存在 安装"
#         apt-get install unzip -y
#         echo "unzip: /usr/bin/unzip 安装成功"
#     else
#         echo "unzip: /usr/bin/unzip 存在"
#     fi
#     # 检查wget
#     if [ ! -f "/usr/bin/wget" ]; then
#         echo "wget: /usr/bin/wget 不存在 安装"
#         apt-get install wget -y
#         echo "wget: /usr/bin/wget 安装成功"
#     else
#         echo "wget: /usr/bin/wget 存在"
#     fi
# }



# 判断文件夹是否存在
# function If_Path(){
#     if [ ! -d "${PX_HOME}/${1}" ]; then
#         echo "路径: ${PX_HOME}/${1} 不存在 创建"
#         mkdir -p ${PX_HOME}/${1}
#     fi
# }

# 重启Xray
# function Restart_Xray(){
#     #If_Service
#     cp ${PX_HOME}/systemd/xray* /etc/systemd/system/
#     systemctl daemon-reload
#     systemctl enable --now xray-update.timer
#     systemctl enable --now xray.service
#     systemctl restart xray
# }


function main(){
    # #判断当前发行版
    # if [ -f "/etc/os-release" ];
    # then
    #     # Debian
    #     # debian_check_tool
    #     # If_Xray
    #     # If_Version
    #     # Restart_Xray
    #     echo "debian todo"
    # elif [ -f "/etc/arch-release" ];
    # then
    #     # Arch
    #     echo "当前为ArchLinux"
    #     # 检查工具安装
    #     arch_check_tool
    #     # 检查路径
    #     Check_dir
    #     # 检查Service
    #     If_Service
    #     # 检查Xray执行文件
    #     If_Xray
    #     # 检查版本
    #     If_Version
    # else
    #     echo "未知发行版"
    # fi
    
    # Arch
    echo "当前为ArchLinux"
    # 检查工具安装
    arch_check_tool
    # 检查路径
    Check_dir
    # 检查Service
    If_Service
    # 检查Xray执行文件
    If_Xray
    # 检查版本
    If_Version
}

main


