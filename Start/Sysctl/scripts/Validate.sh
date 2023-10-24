#! /bin/bash

echo "应为262144"
ulimit -Sn
echo "应为524288"
ulimit -Hn
echo "应为4194304"
cat /proc/sys/fs/file-max

echo "应为BBR br_netfilter"
lsmod | grep bbr
lsmod | grep br_netfilter
echo "应为33554432"
sysctl net.core.rmem_max
echo "应为bbr cake"
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
