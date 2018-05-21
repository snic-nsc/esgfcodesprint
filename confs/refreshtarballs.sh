#!/bin/bash

for i in `ls *.tgz`; do
    rm -rf todel
    mkdir -p todel
    lead=`echo $i|cut -d '-' -f1-2`;
    cp $lead-esgfcerts.tgz todel
    pushd todel && uz $lead-esgfcerts.tgz && rm -f $lead-esgfcerts.tgz
    wget https://esg-dn2.nsc.liu.se/certtarballs/$lead.demonet.local.tgz
    uz $lead.demonet.local.tgz && rm $lead.demonet.local.tgz
    tar -cvzf $lead-esgfcerts.tgz * && mv $lead-esgfcerts.tgz ..
    bash ../checkcertsanity.sh
    popd
done
