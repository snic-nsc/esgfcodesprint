#!/bin/bash

majver=2.8
subver=0
devel=1

if [ ! -s /usr/local/bin/esg-purge.sh ]; then
    echo "No esg-purge.sh file found; possibly nothing to purge.";
    else 
    source /usr/local/bin/esg-purge.sh && esg-purge all && rm -f /etc/yum.repos.d/esgf.repo;
fi


while [ 1 ]; do
    read -p "Major version: $majver, subversion $subver, devel=$devel. If you want to change, press n, any other key to continue " choice;
    if [ "$choice" != 'n' ]; then
        break;
    fi
    read -p "Enter major version " majver
    read -p "Enter subversion " subver
    read -p "Enter devel " devel
done

sed "s/develval/$devel/" fetchbootstrap.tmpl >fetchbootstrap.sh
sed -i "s/rmversion/$majver/" fetchbootstrap.sh
sed -i "s/rsversion/$subver/" fetchbootstrap.sh
bash fetchbootstrap.sh

if [ ! -s esg-autoinstall.conf ]; then
    echo "No local copy of esg-autoinstall.conf found. Copy /usr/local/etc/esg-autoinstall.conf here, modify it with values suitable to you, and try again.";
    exit -1;
fi
cp esg-autoinstall.conf /usr/local/etc/esg-autoinstall.conf
echo "You are all set. If you have the right values setup in esg-autoinstall.conf, you can execute the following:"
dts=`date +"%Y%m%d%H%M"`
relname=`esg-node --version|grep Version|cut -d ' ' -f2`
outname="installation.log-$relname-$dts"
echo "script -c '/usr/local/bin/esg-autoinstall' $outname"
