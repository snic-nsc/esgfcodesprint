#!/bin/bash
mkdir -p todel
rm -rf todel/*
cp *.tgz todel
pushd todel || exit -1;
for i in `ls *.tgz`; do 
    rm -f *.pem; 
    tar -xzf $i; 
    openssl x509 -in hostcert.pem -noout -subject -dates; 
    if [ -s cacert.pem ]; then 
        openssl x509 -in cacert.pem -noout -subject -dates; 
    fi; 
done
popd && rm -rf todel
