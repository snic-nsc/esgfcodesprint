#!/bin/bash
cd /root/scripts

doLookup(){
	cabundle="$1";
	sl=0	
	lead='-----BEGIN CERTIFICATE-----'
	end='-----END CERTIFICATE-----'
	cat $cabundle|tr -d "\r"|while read line; do
		#if [ "$line" = "$lead" ]; then
		if echo "$line"|grep -e "$lead" >/dev/null; then
			sl=1;
			lastcert="$lead\n"; 
			continue
		fi; 
		if [ $sl -eq 1 ]; then 
			#if [ "$line" = "$end" ]; then 
			if echo "$line"|grep -e "$end" >/dev/null; then
				sl=0;
				lastcert=${lastcert}$end"\n"; 
				res=`echo -e "$lastcert"|openssl x509 -noout -issuer_hash -subject`;
				echo -e "$res"|while read ln; do
				res=`echo $ln|cut -d "=" -f2-`;
				echo -n "$res:";
				done
				echo "";
				#ihash=`openssl x509 -in lc.pem -noout -issuer_hash`;
				#enddate=`openssl x509 -in fc.pem -noout -enddate|cut -d '=' -f2-|tr -s ' '`;
				#subject=`openssl x509 -in fc.pem -noout -subject|cut -d ' ' -f2-`;
				#expdate=`echo $enddate |awk '{print $1" "$2" "$4}'`;
				#daysremaining=`python /root/scripts/daysto.py "$expdate"`;
				#continue; 
			fi;
			lastcert=${lastcert}$line"\n"; 
		fi; 
	done
}
if [ $# -ne 1 ]; then
	echo "Need ca bundle. Bailing out";
	exit -1;
fi

doLookup "$1";
