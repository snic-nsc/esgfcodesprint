#!/bin/bash
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

#Copy additional CORDEX specific configuration entries to ESGINI
	cat handout.ini >>$ESGINI

#Add CORDEX and other model table entries to esgcet_models_table 
	cat modeladds >> /esg/config/esgcet/esgcet_models_table.txt

#Add CORDEX to list of projects in ESGINI
	#matchtext='test | Test Project | 3'
	#quotedmatchtext=`echo $matchtext|sed 's/[./*?#\t]/\\\\&/g'`
	#quotedadd=`echo "cordex | CORDEX | 4"|sed 's/[./*?#\t]/\\\\&/g'`
	#sed -i "s/$quotedmatchtext/$quotedmatchtext\\n\\t$quotedadd/" $ESGINI

#Copy modified policies and ats (attribute service) files /esg/config
	cp *.xml /esg/config/

#Update publisher database with new entries
	/usr/local/uvcdat/2.2.0/bin/esginitialize -c 2>&1|tee esginit.out
