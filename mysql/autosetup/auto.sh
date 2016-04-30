#!/bin/bash
#filename: install_mysql.sh
#function: use rpm package install mysql
 
#安装mysql的rpm包
mysql_instpkg1="MySQL-server-5.0.16-0.i386.rpm"
mysql_instpkg2="MySQL-client-5.0.16-0.i386.rpm"
 
#安装日志文件
mysql_instlog="install_mysql.log"
mysql_instlog="`pwd`"/"$mysql_instlog"
 
#参数检查
if [ "$#" -gt "1" ];then
    echo "usage: ./install_mysql [dir_instpkg]" | tee $mysql_instlog
    exit 1
elif [ "$#" -eq "1" ];then
    dir_instpkg="$1"
    if [ ! -d "$dir_instpkg" ];then
        echo "$dir_instpkg is not a dirctory" | tee $mysql_instlog
        exit 1
    fi
else
    dir_instpkg="`pwd`"
fi
 
#检查系统是否已经安装了mysql
rpm -qa | grep 'MySQL'
if [ $? == 0 ];then
    echo "mysql is installed" | tee $mysql_instlog
    exit 1
fi
 
dir_inst="/usr/mysql"
mkdir $dir_inst
cp $dir_instpkg/$mysql_instpkg1 $dir_inst
if [ $? != 0 ];then
    echo "cp $dir_instpkg/$mysql_instpkg1 $dir_inst is fail" | tee $mysql_instlog
    exit 1
fi
 
cp $dir_instpkg/$mysql_instpkg2 $dir_inst
if [ $? != 0 ];then
    echo "cp $dir_instpkg/$mysql_instpkg2 $dir_inst is fail" | tee $mysql_instlog
    exit 1
fi 
           
cd $dir_inst
rpm -ivh $mysql_instpkg1 && rpm -ivh $mysql_instpkg2
 
#检查安装成功否
rpm -qa | grep 'MySQL'
if [ $? != 0 ];then
    echo "mysql install fail" | tee $mysql_instlog
    exit 1
else
    echo "mysql isntall success" | tee $mysql_instlog
fi
 
#启动mysql
#/etc/rc.d/init.d/mysql start
service mysql start
if [  $? == 0 ];then
    echo "start mysql is success" | tee $mysql_instlog
else
    echo "start mysql is fail" | tee $mysql_instlog
fi
