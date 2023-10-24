#!/usr/bin/bash

#############
# File    :   postgresql-post.sh
# Time    :   2023/01/02 22:06:15
# Author  :   Yah
# Version :   1.0
# License :   MIT
# Desc    :   None
#############

/usr/bin/sed -i "s|Group=postgres|Group=postgres\nRestart=always\nRestartSec=10s\nStartLimitInterval=60|g" /usr/lib/systemd/system/postgresql.service
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl restart postgresql
