#!/usr/bin/bash


#############
# File    :   postgresql-post.sh
# Time    :   2023/01/02 22:06:15
# Author  :   Yah
# Version :   1.0
# Contact :   wangixoaerwex@outlook.com
# License :   MIT
# Desc    :   None
#############


/usr/bin/sed -i "s|After=network.target|After=wg-quick@wg0.service\nRequires=wg-quick@wg0.service|g" /usr/lib/systemd/system/postgresql.service
/usr/bin/sed -i "s|Group=postgres|Group=postgres\nRestart=always\nRestartSec=10s\nStartLimitInterval=60|g" /usr/lib/systemd/system/postgresql.service
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl restart postgresql