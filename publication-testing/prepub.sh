#!/bin/bash

if [ "$HOSTNAME" = "esg-idx.demonet.local" ]; then
    yum install -y python-argparse python-psycopg2
    python usermgmt.py --enable-extpub esg-idx.demonet.local <yes
    python usermgmt.py --enable-localgroups
fi

#Export ESGINI and backup ESGINI and other xml files, prior to making changes
	mkdir -p backups 2>/dev/null;
	dtstr=`date +%Y-%m-%d_%H-%M-%S`;
	export ESGINI=/esg/config/esgcet/esg.ini
	cp $ESGINI backups/esg.ini-$dtstr;
	cp /esg/config/esgf_ats_static.xml backups/esgf_ats_static.xml-$dtstr
	cp /esg/config/esgf_policies_local.xml backups/esgf_policies_local.xml-$dtstr

#Copy test file to /esg/data and unpack
	cp testdatafile.tgz /esg/data/
	pushd /esg/data && tar -xzf testdatafile.tgz && rm -f testdatafile.tgz
	popd

#Add CORDEX to list of projects in ESGINI
    if grep 'cordex | CORDEX | 4' $ESGINI >/dev/null; then 
        echo "CORDEX definition already present in $ESGINI";
    else 
	    matchtext='test | Test Project | 3'
	    quotedmatchtext=`echo $matchtext|sed 's/[./*?#\t]/\\\\&/g'`
	    quotedadd=`echo "cordex | CORDEX | 4"|sed 's/[./*?#\t]/\\\\&/g'`
	    sed -i "s/$quotedmatchtext/$quotedmatchtext\\n\\t$quotedadd/" $ESGINI
    fi

#Copy modified policies and ats (attribute service) files /esg/config
	cp *.xml /esg/config/

#Update publisher database with new entries
source /usr/local/conda/bin/activate esgf-pub
export UVCDAT_ANONYMOUS_LOG=false
esginitialize -c 2>&1|tee esginit.out
