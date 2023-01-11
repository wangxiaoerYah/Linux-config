#!/usr/bin/bash


#############
# File    :   postgresql-pre.sh
# Time    :   2023/01/02 22:03:21
# Author  :   Yah
# Version :   1.0
# Contact :   wangixoaerwex@outlook.com
# License :   MIT
# Desc    :   None
#############


function pre(){
    # 获取旧版Postgresql版本
    echo "PG升级前版本: $(cat /var/lib/postgres/data/PG_VERSION)"
    cat /var/lib/postgres/data/PG_VERSION > /tmp/OLD_PG_VERSION
    chown postgres:postgres /tmp/OLD_PG_VERSION
    cp -r /var/lib/postgres/data /var/lib/postgres/olddata
    chown postgres:postgres -R /var/lib/postgres
    chown postgres:postgres -R /var/lib/postgres/olddata
}

pre