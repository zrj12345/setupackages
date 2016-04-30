#!/bin/sh
#----- REDIS 安装脚本 ----
#支持联网安装,必须事先安装有wget
#

filename=""
get_url=http://download.redis.io/releases/
filename="redis-3.0.7.tar.gz"
function get_redis_package {
	clear
	echo "Not:You Can Get leaste Release Package From http://download.redis.io/releases/ Or Not"
	echo "After Choice ,You Must Assign a Package Name like \"redis-3.0.7.tar.gz\""
	echo "Otherwise Default Package Will Be Installed"
	echo "Press q to exit"
	read -p "Fill Package or \"Enter\" If you Choice Default Package:" packagename
	if test ${packagename}
	then {
		clear
		echo ss
		filename=${packagename}
		wget ${get_url}${packagename}
	} else {
		clear
		echo 'filename'${filename}
		wget ${get_url}${filename}
	}
		
	fi
}

declare -i  suffix_result
function get_suffix {
	echo '$1:'$1
	for suffix in "tar.gz" "zip" 
	do 
		if [ $suffix = $1 ]
		then
			suffix_result=0
			return 0
		else 
			return 1
		fi
	done
}

function daemonize {
	which sed  > /dev/null
	if [ $? -eq 0 ] 
	then 
		`whereis sed | awk '{print $2}'` -i '/daemonize no/s/no/yes/g/g' ${filename}
	fi
}

function setup_start {
	get_redis_package
	echo "first result:"$?
	get_suffix $filename
	echo 'second result:'$?
	if [ $? -eq 0 ];
	then
		tar -zxvf ${filename}
		filename="${filename%.*}"
		filename="${filename%.*}"
		echo ${filename}
		cd ${filename}
		#make && make install 
	fi
	clear
	echo "Please Check Whether Package Is Installed Or Not"
}


echo  "1.Install From Network Using Wget Tool"  
echo  "2.Install From Local Disk"
echo  "3.Press Q To Exit"
echo -n "Please Make a Choice:"

read  choice
     
case $choice in
		1)
		setup_start
		;;
		2)
		echo "you choice 2"
		;;
		*)
		echo "exit"
esac
