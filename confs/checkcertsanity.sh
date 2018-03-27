#/bin/bash

do_checks(){
csr=$1
cert=$2
key=$3

echo "Looking for request called $csr, key called $key and cert called $cert";
keyval='';
if [ -f $key ]; then 
	keyval=`openssl rsa -noout -modulus -in $key|openssl md5`
fi
certval=`openssl x509 -noout -modulus -in $cert|openssl md5`
reqval=`openssl req -noout -modulus -in $csr|openssl md5`
if [ "$keyval" != "" ]; then
	if [ "$keyval" = "$certval" ] && [ "$keyval" = "$reqval" ]; then
		echo "All values are concurrent ($reqval)";
	else
		echo "keyval is $keyval, certval is $certval, reqval is $reqval";
		exit
	fi
else 
	if [ "$reqval" = "$certval" ]; then
		echo "All values are concurrent ($reqval)";
	else
		echo "certval is $certval, reqval is $reqval";
		exit
	fi
fi
openssl x509 -in $cert -subject -startdate -enddate -issuer_hash -hash -noout
openssl x509 -in $cert -noout -purpose|grep CA
openssl x509 -inform pem -in  $cert -outform pem
}
do_checks hostcert_req.csr hostcert.pem hostkey.pem
openssl x509 -in hostcert.pem -text|grep DNS
if [ -s cacert.pem ]; then
    do_checks cacert_req.csr cacert.pem cakey.pem
fi


