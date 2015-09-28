#!/bin/bash

if [ "$#" -eq 0 ]; then 
	echo "Enter eth device id (eth0/eth1 etc)";
	exit -1;
fi

device=$1;
ip addr show $device|head -2|tail -1|awk '{print $2}'|tr '[:lower:]' '[:upper:]' 

