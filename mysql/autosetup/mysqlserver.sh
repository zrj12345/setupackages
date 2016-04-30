#!/bin/sh
##############################################################################
# NOTE:
# The test system is Ubuntu12.04
# This Scripts all rights reserved deserved by MickeyZZC
# Copyright  2013
#
##############################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#clear
######ȫ�ֱ�������#######
username=root
passwd=000000
mysqlhost=""
backuppath=`pwd`
#########################
#MYSQL���״̬���
mysqllive(){
    num=0
    while [[ `pidof mysqld` == "" ]] ; do
        echo "$(date +%Y%m%d%H%M),MYSQL IS DOWN" >> /var/log/mysqlstat.log
        service mysql start
        num=`expr $num + 1`
            if [ $num -gt 11 ] ; then
                echo "$(date +%Y%m%d%H%M),MYSQL NO UP" >> /var/log/mysqlstat.log
                exit 1
            fi
        sleep 10
    done
    #���������ϵ����ݿ⸳ֵ���������
    mysqldata=`mysql -h$mysqlhost -u$username -p$passwd -e"show databases"|grep -vE "mysql|information_schema|performance_schema|Database"`
    if [ $num -gt 0 ] ; then
        mysqlsamchk
    fi
     
}
#MYSQL������޸�
mysqlsamchk(){
#MYSQL���״̬���
    mysqllive
    if [[ `which mysqlcheck` == "" ]] ;then
        for i in ${mysqldata[@]} ; do
            mytables=`mysql -h$mysqlhost -u$username -p$passwd -e"use $i;show tables;"|grep -vE "Tables_in_"`
            for j in ${mytables[@]} ; do
                table_status=`mysql -h$mysqlhost -u$username -p$passwd -e"check table $i.$j"|awk 'BEGIN{IFS='\t'}{print $3}'|grep "error"`
                if [[ ! "$table_status" == "" ]] ; then
                    mysql -h$mysqlhost -u$username -p$passwd -e"repair table $i.$j"
                    echo "$(date +%Y%m%d%H%M),$i.$j be repair" >> /var/log/mysqlstat.log
                fi
            done
        done
    else
        mysqlcheck --all-databases --auto-repair -u$username -p$passwd |awk '!/OK/ {printf "datetime,%s\n",$1}'|sed "s/datetime/$(date +%Y%m%d%H%M)/g" >> /var/log/mysqlstat.log
    fi
}
#�������ݿ�
mysqlbackup() {
#MYSQL���״̬���
mysqllive
[ ! -d $backuppath ] && mkdir $backuppath
for i in ${mysqldata[@]}
do
#������ռ���ڱ��ݻ�Ƚ��ȵ�һ��
    find $backuppath -name $i\_*.zip -type f -mtime +7 -exec rm {} \;
#���ݺ�ѹ������
    mysqldump --opt -h$mysqlhost -u$username -p$passwd $i |gzip > $backuppath/$i\_$(date +%Y%m%d%H%M).zip
done
}
#FTP�ϴ����ݱ���
dataftp() {
######��������#######
ftphost=''
ftpusr=''
ftpd=''
ftpcmd=''
###################
#���ɱ������ݰ���MD5�ļ��Ŵ�
tmp="/tmp/$(date +%Y%m%d)"
[ ! -f $tmp ] && touch $tmp
for j in $(ls $backuppath/*$(date +%Y%m%d)* ); do
    cd $backuppath ; md5sum `basename $j` >> $tmp
    #����PYTHONд��FTP�ű��ϴ����ݣ������ַ��http://www.oschina.net/code/snippet_217347_25497
    python $ftpcmd -t upload -H $ftphost -u $ftpusr -p $ftpd -l $j -r "/${j##*/}"
done
python $ftpcmd -t upload -H $ftphost -u $ftpusr -p $ftpd -l $tmp -r $(date +%Y%m%d)
rm $tmp
}
echo sssssss
case $1 in
'check')
    mysqlsamchk ;;
'backup')
    mysqlbackup
    dataftp ;;
*)
    mysqllive ;;
esac
