#!/bin/bash
JAVA='/usr/local/java/bin/java'
nodelist='esg-data.demonet.local'
pushd /usr/local/tomcat/webapps/esg-search/WEB-INF/classes || exit -1;

for node in $nodelist; do
        echo $node;
        $JAVA -Dlog4j.configuration=./log4j.xml -Djava.ext.dirs=../lib esg.search.publish.impl.PublishingServiceMain http://$node/thredds/catalog/catalog.xml '*' THREDDS true /tmp/solrpub_$node.log
done
