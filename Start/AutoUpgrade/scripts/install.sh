#!/bin/bash


#############
# File    :   install.sh
# Time    :   2022/10/16 13:58:32
# Author  :   Yah
# Version :   1.0
# Contact :   wangixoaerwex@outlook.com
# License :   MIT
# Desc    :   None
#############

if [ $(uname -m) == "aarch64" ]; then
    echo "当前机器为: arm64"
    if [ -f "/etc/pacman.d/hooks/99-kernel-rename.hook" ]; then
        echo "重命名: 99-kernel-rename.hook -> 98-kernel-rename.hook"
        mv /etc/pacman.d/hooks/99-kernel-rename.hook /etc/pacman.d/hooks/98-kernel-rename.hook
    fi
    mkdir -p /etc/pacman.d/hooks
    wget -q -O /etc/pacman.d/hooks/99-linux-kernel.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/99-linux-kernel-arm64.hook
else
    mkdir -p /etc/pacman.d/hooks
    wget -q -O /etc/pacman.d/hooks/99-linux-kernel.hook https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/pacman.d/hooks/99-linux-kernel.hook
    echo "list"
    ls /etc/pacman.d/hooks
    
fi


wget -q -O /etc/systemd/system/pacman-auto-upgrade.service https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/pacman-auto-upgrade.service
wget -q -O /etc/systemd/system/pacman-auto-upgrade.timer https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system/pacman-auto-upgrade.timer
systemctl enable --now pacman-auto-upgrade.timer


