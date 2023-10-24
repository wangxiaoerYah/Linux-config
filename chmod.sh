#!/bin/bash

#修改install-scripts目录以及子目录的所有以.sh结尾的文件的可执行权限

for file in $(find . -name "*.sh"); do
	chmod +x $file
	shfmt -w $file
done
