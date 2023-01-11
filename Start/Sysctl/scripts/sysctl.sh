#! /bin/bash

#security
rm -rf /etc/security/limits.d/*
rm -rf /etc/security/limits.conf
wget -q -O /etc/security/limits.conf https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/security/limits.conf
##systemd
wget -q -O /etc/systemd/user.conf https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/user.conf
wget -q -O /etc/systemd/system.conf https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/systemd/system.conf

#modprobe
rm -rf /etc/modules-load.d/*
wget -q -O /etc/modules-load.d/tcp.conf https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/modules-load.d/tcp.conf

#sysctl
rm -rf /etc/sysctl.conf
rm -rf /etc/sysctl.d
mkdir -p /etc/sysctl.d
wget -q -O /etc/sysctl.d/99-sysctl.conf https://raw.githubusercontent.com/wangxiaoerYah/Linux-config/main/root/etc/sysctl.d/99-sysctl.conf

reboot

