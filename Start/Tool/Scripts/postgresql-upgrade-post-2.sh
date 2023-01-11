#!/usr/bin/bash


#############
# File    :   postgresql-upgrade-post-2.sh
# Time    :   2023/01/02 23:20:29
# Author  :   Yah
# Version :   1.0
# Contact :   wangixoaerwex@outlook.com
# License :   MIT
# Desc    :   None
#############


function upgrade(){
    OLD_PG_VERSION=$(cat /tmp/OLD_PG_VERSION)
    cd /var/lib/postgres/tmp
    initdb -D /var/lib/postgres/data --locale=en_US.UTF-8 --encoding=UTF8 --data-checksums
    pg_upgrade -b /opt/pgsql-${OLD_PG_VERSION}/bin -B /usr/bin -d /var/lib/postgres/olddata -D /var/lib/postgres/data
    cp /var/lib/postgres/olddata/postgresql.conf /var/lib/postgres/data/postgresql.conf
    cp /var/lib/postgres/olddata/pg_hba.conf /var/lib/postgres/data/pg_hba.conf
    rm -rf /var/lib/postgres/olddata
    rm -rf /var/lib/postgres/tmp
    rm -rf /tmp/OLD_PG_VERSION
}


if [ $(postgres --version | grep -o '[0-9]*\.[0-9]*' | awk -F'.' '{print $1}' | tr -d '\n') -lt $(cat /tmp/OLD_PG_VERSION) ]; then
    upgrade
else
    echo "删除PATH: /tmp/OLD_PG_VERSION"
    rm -rf /tmp/OLD_PG_VERSION
fi
