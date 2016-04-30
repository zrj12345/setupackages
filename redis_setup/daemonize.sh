#!/bin/sh


function daemonize {
	which sed  > /dev/null
	if [ $? -eq 0 ] 
	then 
		`whereis sed | awk '{print $2}'` -i '/daemonize no/s/no/yes/g/g' $1	
	fi
}

daemonize $1

