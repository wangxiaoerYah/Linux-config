#!/usr/bin/bash

#############
# File    :   postgresql-upgrade-post-2.sh
# Time    :   2023/01/02 23:20:29
# Author  :   Yah
# Version :   1.0
# License :   MIT
# Desc    :   None
#############

function upgrade() {
	OLD_PG_VERSION=$(cat /var/lib/postgres/olddata/PG_VERSION)
	cd /var/lib/postgres/tmp
	initdb -D /var/lib/postgres/data --locale=C.UTF-8 --encoding=UTF8 --data-checksums
	pg_upgrade -b /opt/pgsql-${OLD_PG_VERSION}/bin -B /usr/bin -d /var/lib/postgres/olddata -D /var/lib/postgres/data
	cp /var/lib/postgres/olddata/postgresql.conf /var/lib/postgres/data/postgresql.conf
	cp /var/lib/postgres/olddata/pg_hba.conf /var/lib/postgres/data/pg_hba.conf
	rm -rf /var/lib/postgres/olddata
	rm -rf /var/lib/postgres/tmp
}

if [ ! -d "/var/lib/postgres/olddata" ]; then
	echo "未找到/var/lib/postgres/olddata文件夹,无需迁移."
else
	if [ $(postgres --version | grep -o '[0-9]*\.[0-9]*' | awk -F'.' '{print $1}' | tr -d '\n') -lt $(cat /var/lib/postgres/olddata/PG_VERSION) ]; then
		upgrade
	fi
fi
