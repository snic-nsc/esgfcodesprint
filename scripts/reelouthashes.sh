#!/bin/bash

doLookup(){
	cabundle="$1";
	trm=0;
	silent=0;
	if [ ! -e $cabundle ]; then
		echo "Ca Bundle not found. Provide full path, if not in pwd";
		exit -1; 
	fi
	if [ "$2" != "none" ]; then
		if [ "$2" = "trim" ]; then
			trm=1;
			echo -n >posttrim;
		else
			silent=1;
			wanted=$2;
		fi
	else 
		silent=0;
	fi
	sl=0	
	lead='-----BEGIN CERTIFICATE-----'
	end='-----END CERTIFICATE-----'
	numl=`cat $cabundle|tr -d "\r"|wc -l`;
	for i in `seq 1 $numl`; do
		line=`head -$i $cabundle|tail -1`;
	#cat $cabundle|tr -d "\r"|while read line; do
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
				issuerhash=`echo -e "$lastcert"|openssl x509 -noout -issuer_hash`;
				hash=`echo -e "$lastcert"|openssl x509 -noout -hash`;
				
				if [ $silent -eq 1 ]; then
					if [ "$wanted" != "$hash" ]; then
						continue;
					fi
					subject=`echo -e "$lastcert"|openssl x509 -noout -subject|cut -d ' ' -f2-`;
					echo "$hash:$issuerhash $subject";
					echo -e $lastcert;
					break;
				fi
						
				subject=`echo -e "$lastcert"|openssl x509 -noout -subject|cut -d ' ' -f2-`;
				echo "$hash:$issuerhash $subject";
				if [ $trm -eq 1 ]; then
					echo "If you wish to discard, press d, any other key to retain this certificate";
					read resp;
					if [ "$resp" != "d" ]; then
						echo -e "$lastcert"|awk 'NF' >>posttrim;
					fi
				fi
			fi;
			lastcert=${lastcert}$line"\n"; 
		fi; 
	done
}
if [ $# -lt 1 ]; then
	echo "Need ca bundle. Bailing out";
	exit -1;
fi
if [ $# -eq 1 ]; then
	doLookup "$1" "none";
 elif [ $# -eq 2 ]; then
	doLookup "$1" "$2";
fi
