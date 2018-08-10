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
tofix=0
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
if [ ! -s esg-autoinstall.conf ]; then
    echo "No local copy of esg-autoinstall.conf found. Copy /usr/local/etc/esg-autoinstall.conf here, modify it with values suitable to you, and try again.";
    exit -1;
fi
cp esg-autoinstall.conf /usr/local/etc/esg-autoinstall.conf
echo "You are all set. If you have the right values setup in esg-autoinstall.conf, you can execute the following:"
dts=`date +"%Y%m%d%H%M"`
relname=`esg-node --version|grep Version|cut -d ' ' -f2`
outname="upgrade.log-$relname-$dts"
echo "script -c '/usr/local/bin/esg-autoinstall' $outname"
