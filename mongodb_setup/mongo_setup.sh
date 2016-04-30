#!/bin/sh

filename=/etc/yum.repos.d/mongodb-org-3.2.repo
rm -rf ${filename} && touch ${filename}
echo "[mongodb-org-3.2]" > ${filename}
echo "name=MongoDB Repository" >> ${filename}
echo "baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/" >> ${filename}
echo "gpcheck=1"   >> ${filename}
echo "enable=1" >>  ${filename}
#echo "exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools" >> ${filename}

sudo yum install -y mongodb-org
sed -i '/SELINUX=/s/enable/disable/g' /etc/selinux/config	
semanage port -a -t mongod_port -p tcp 27017
chkconfig mongod on
service mongod start
tail -f /var/log/mongodb/mongod.log 

