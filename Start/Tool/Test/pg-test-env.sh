#!/usr/bin/bash

#############
# File    :   pg-test-env.sh
# Time    :   2023/01/02 22:53:14
# Author  :   Yah
# Version :   1.0
# License :   MIT
# Desc    :   None
#############

systemctl stop postgresql.service
rm -rf /var/lib/postgres/data
rm -rf /var/lib/postgres/tmp
mkdir -p /var/lib/postgres/data
mkdir -p /var/lib/postgres/tmp
chown postgres:postgres -R /var/lib/postgres
