#!/usr/bin/bash

#############
# File    :   pg-test.sh
# Time    :   2023/01/02 22:45:24
# Author  :   Yah
# Version :   1.0
# License :   MIT
# Desc    :   None
#############

echo "查看目录"
ls -al /var/lib/postgres

echo "切换目录"
cd /var/lib/postgres/tmp
echo "当前路径"
pwd
echo "初始化数据库"
initdb --locale=en_US.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data --data-checksums
echo "删除tmp目录"
rm -rf /var/lib/postgres/tmp
echo "查看目录"
ls -al /var/lib/postgres
