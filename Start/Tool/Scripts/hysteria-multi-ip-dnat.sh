#!/usr/bin/bash

#############
# File    :   hysteria-multi-ip-dnat.sh
# Time    :   2023/05/15 19:30:16
# Author  :   Yah
# Version :   1.0
# Contact :   Yah
# License :   MIT
# Desc    :   None
#############

# if [[ $(ip -4 addr show dev ${HYSTERIA_NET_INTERFACE} | grep 'scope global' | wc -l) -gt 0 ]]; then
#     IP4_array=$(ip -4 addr show dev ${HYSTERIA_NET_INTERFACE} | grep 'scope global' | awk '{print $2}' | cut -d '/' -f 1)
#     IP4_Default_Src=$(ip -4 route get 1.1.1.1 | grep -oP '(?<=src )(\S+)')
#     # if iptables Hysteria-Multi-ip-DNAT rules not exist then create it
#     # else flush it
#     if [[ $(/usr/bin/iptables -t nat -S | grep 'Hysteria-Multi-ip-DNAT' | wc -l) -eq 0 ]]; then
#         /usr/bin/iptables -t nat -N Hysteria-Multi-ip-DNAT
#     else
#         /usr/bin/iptables -t nat -F Hysteria-Multi-ip-DNAT
#         /usr/bin/iptables -t nat -F PREROUTING
#     fi
#     # Set iptables rules
#     ## ipv4
#     /usr/bin/iptables -t nat -A Hysteria-Multi-ip-DNAT -p udp -m udp --dport ${HYSTERIA_DPORT} -j DNAT --to-destination ${IP4_Default_Src}${HYSTERIA_TPORT}
#     for ip in ${IP4_array[@]}; do
#         /usr/bin/iptables -t nat -A PREROUTING  -p udp -m udp --dport ${HYSTERIA_DPORT} -d ${ip} -j Hysteria-Multi-ip-DNAT
#     done
# fi

# # if Network has ipv6 then get ipv6 address
# if [[ $(ip -6 addr show dev ${HYSTERIA_NET_INTERFACE} | grep 'scope global' | wc -l) -gt 0 ]]; then
#     IP6_array=$(ip -6 addr show dev ${HYSTERIA_NET_INTERFACE} | grep 'scope global' | awk '{print $2}' | cut -d '/' -f 1)
#     IP6_Default_Src=$(ip -6 route get 2606:4700:4700::1111 | grep -oP '(?<=src )(\S+)')
#     # if ip6tables Hysteria-Multi-ip-DNAT rules not exist then create it
#     # else flush it
#     if [[ $(/usr/bin/ip6tables -t nat -S | grep 'Hysteria-Multi-ip-DNAT' | wc -l) -eq 0 ]]; then
#         /usr/bin/ip6tables -t nat -N Hysteria-Multi-ip-DNAT
#     else
#         /usr/bin/ip6tables -t nat -F Hysteria-Multi-ip-DNAT
#         /usr/bin/ip6tables -t nat -F PREROUTING
#     fi
#     ## ipv6
#     /usr/bin/ip6tables -t nat -A Hysteria-Multi-ip-DNAT -p udp -m udp --dport ${HYSTERIA_DPORT} -j DNAT --to-destination [${IP6_Default_Src}]${HYSTERIA_TPORT}
#     for ip in ${IP6_array[@]}; do
#         /usr/bin/ip6tables -t nat -A PREROUTING  -p udp -m udp --dport ${HYSTERIA_DPORT} -d ${ip} -j Hysteria-Multi-ip-DNAT
#     done
# fi

# IPv4
if [[ $(/usr/bin/iptables -t nat -S | grep 'Hysteria-Multi-ip-DNAT' | wc -l) -eq 0 ]]; then
	/usr/bin/iptables -t nat -N Hysteria-Multi-ip-DNAT
else
	/usr/bin/iptables -t nat -F Hysteria-Multi-ip-DNAT
	/usr/bin/iptables -t nat -F PREROUTING
fi
/usr/bin/iptables -t nat -A Hysteria-Multi-ip-DNAT -p udp -m udp --dport ${HYSTERIA_DPORT} -j DNAT --to-destination ${HYSTERIA_TPORT}
/usr/bin/iptables -t nat -A PREROUTING -i ${HYSTERIA_NET_INTERFACE} -p udp -m udp --dport ${HYSTERIA_DPORT} -j Hysteria-Multi-ip-DNAT

# IPv6
if [[ $(/usr/bin/ip6tables -t nat -S | grep 'Hysteria-Multi-ip-DNAT' | wc -l) -eq 0 ]]; then
	/usr/bin/ip6tables -t nat -N Hysteria-Multi-ip-DNAT
else
	/usr/bin/ip6tables -t nat -F Hysteria-Multi-ip-DNAT
	/usr/bin/ip6tables -t nat -F PREROUTING
fi
/usr/bin/ip6tables -t nat -A Hysteria-Multi-ip-DNAT -p udp -m udp --dport ${HYSTERIA_DPORT} -j DNAT --to-destination ${HYSTERIA_TPORT}
/usr/bin/ip6tables -t nat -A PREROUTING -i ${HYSTERIA_NET_INTERFACE} -p udp -m udp --dport ${HYSTERIA_DPORT} -j Hysteria-Multi-ip-DNAT
