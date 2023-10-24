#!/usr/bin/bash

#############
# File    :   postgresql-pre.sh
# Time    :   2023/01/02 22:03:21
# Author  :   Yah
# Version :   1.0
# License :   MIT
# Desc    :   None
#############

function pre() {
	systemctl stop postgresql.service
	cp -r /var/lib/postgres/data /var/lib/postgres/olddata
	echo "PG升级前版本: $(cat /var/lib/postgres/olddata/PG_VERSION)"
	chown postgres:postgres -R /var/lib/postgres
	chown postgres:postgres -R /var/lib/postgres/olddata
}

pre
