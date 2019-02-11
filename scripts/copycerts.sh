#!/bin/bash
trustpass=`mkpasswd -s 0`;
hostn=`hostname -a`
if ! [ -e /root/esgfcodesprint2015 ]; then
    ln -s /root/esgfcodesprint /root/esgfcodesprint2015
fi
pushd /root/esgfcodesprint2015/confs && git pull || exit -1;
popd
pushd /etc/esgfcerts
cp /root/esgfcodesprint2015/confs/$hostn-esgfcerts.tgz .
uz $hostn-esgfcerts.tgz
chmod 400 *key.pem
newpipe=0
declare -A ans
ansitems=("trustpass" "trustpass2" "cachain" "chainblank" "infocorrect" "infocorrect2" "keypass" "keypass2");
ans['trustpass']=${trustpass}
ans['trustpass2']=${trustpass}
ans['keypass']=${trustpass}
ans['keypass2']=${trustpass}
ans['cachain']='cachain.pem'
ans['chainblank']=''
ans['infocorrect']='y'
ans['infocorrect2']='y'
echo -n >/tmp/pipeans

if [ ! -e /tmp/inputpipe ]; then
	echo "created new pipe";
	mkfifo /tmp/inputpipe;
	newpipe=1;
fi
esg-node --install-local-certs
for val in ${ansitems[@]}; do
	resp=${ans[$val]};
	echo "writing $resp as value for $val";
	echo "$resp" >>/tmp/pipeans;
done
esg-node --install-keypair ./hostcert.pem ./hostkey.pem </tmp/inputpipe &
while read ln; do 
	echo "$ln" >/tmp/inputpipe;
done </tmp/pipeans
proc=$!;
while [ 1 ]; do
	if ps -ef|grep $proc |grep -v 'grep' >/dev/null; then 
		sleep 10;
	else break;
	fi;
done
rm -f /tmp/inputpipe
esg-node restart
