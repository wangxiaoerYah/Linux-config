#!/usr/bin/bash

#############
# File    :   postgresql-upgrade-post-1.sh
# Time    :   2023/01/02 22:06:15
# Author  :   Yah
# Version :   1.0
# License :   MIT
# Desc    :   None
#############

function backup() {
	systemctl stop postgresql.service
	rm -rf /var/lib/postgres/data
	mkdir -p /var/lib/postgres/tmp
	chown postgres:postgres -R /var/lib/postgres
}

if [ $(postgres --version | grep -o '[0-9]*\.[0-9]*' | awk -F'.' '{print $1}' | tr -d '\n') -lt $(cat /var/lib/postgres/olddata/PG_VERSION) ]; then
	backup
else
	echo "PG升级前版本: $(cat /var/lib/postgres/olddata/PG_VERSION) 与 PG升级后版本: $(postgres --version | grep -o '[0-9]*\.[0-9]*' | awk -F'.' '{print $1}' | tr -d '\n') 一致,无需迁移数据库."
	echo "删除PATH: /var/lib/postgres/olddata"
	rm -rf /var/lib/postgres/olddata
fi
