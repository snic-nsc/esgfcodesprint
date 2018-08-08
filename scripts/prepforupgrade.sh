#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Needed: maj version, sub version  and devel(0/1)"
    exit -1;
fi
release_maj_version=$1
release_sub_version=$2
devel=$2

echo "maj version=$release_maj_version, sub version=$release_sub_version, devel=$devel"
read -e -p $'y/N\n' resp

resp=`echo $resp|tr [A-Z] [a-z]`

if [ "$resp" != 'y' ]; then
    exit -1;
fi

esg-node stop
rm -rf /usr/local/tomcat/webapps/*
rm -rf /usr/local/src

res=`esg-node --version|grep Version|awk {'print $2'}|cut -d '-' -f1|cut -d 'v' -f2`;
tofix=0
if echo $res|grep '2.6' >/dev/null; then
    tofix=1;
    if echo $res|grep '2.6.9' >/dev/null; then
        tofix=0;
    fi
fi
if [ $tofix -eq 1 ]; then
    script -c 'bash tempfix' tempfix_log
fi

if [ $devel -eq 1 ]; then
	wget -O esg-bootstrap.liu http://esg-dn2.nsc.liu.se/esgf/dist/devel/$release_maj_version/$release_sub_version/esgf-installer/esg-bootstrap.liu --no-check-certificate
	chmod 555 esg-bootstrap.liu
	./esg-bootstrap.liu --devel
else
	wget -O esg-bootstrap.liu http://esg-dn2.nsc.liu.se/esgf/dist/$release_maj_version/$release_sub_version/esgf-installer/esg-bootstrap.liu --no-check-certificate
	chmod 555 esg-bootstrap.liu
	./esg-bootstrap.liu

fi
esg-node --version
