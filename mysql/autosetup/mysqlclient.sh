#!/bin/env bash
##############################################################################
# NOTE:
# The test system is Ubuntu12.04
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2013
#
##############################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
########全局变量配置###########
username=root
passwd=000000
mysqlhost=""
backuppath=`pwd`
backuplog=/var/log/mysql_dump.log
###############################
[ ! -f $backuplog ] && touch $backuplog
#用两个小时检测MD5文件是否存在
num=0
while [ ! -f $backuppath/$(date +%Y%m%d) ] ; do
    num=`expr $num + 1`
    sleep 10m
    if [ $num -gt 12 ] ; then
        exit 1
    fi
done
#对比数据库备份包是否已经下载完成
[[ `ls $backuppath/*$(date +%Y%m%d)* |wc -l` == `wc -l $backuppath/$(date +%Y%m%d)` ]] || exit 1 && 
for i in $(ls $backuppath/*$(date +%Y%m%d)* ); do
    tmpdata=`basename $i`
        cd $backuppath
    tmp=`md5sum $tmpdata`
    if [[ `grep $tmp $backuppath/$(date +%Y%m%d)` == "" ]] ;then
        echo "$(date +%Y%m%d%H%M),$tmpdata is damage" >> $backuplog
    else
#导入数据库
        mysql -h$mysqlhost -u$username -p$passwd -e"CREATE DATABASE IF NOT EXISTS ${tmpdata%%_*} CHARACTER SET utf8"
        zcat $i | mysql -h$mysqlhost -u$username -p$passwd ${tmpdata%%_*}
        echo "$(date +%Y%m%d%H%M),$tmpdata is dump" >> $backuplog
    fi
done
rm $backuppath/$(date +%Y%m%d)
