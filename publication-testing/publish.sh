mkdir -p /root/.globus
export ESGINI=/esg/config/esgcet/esg.ini
myproxy-logon -s esg-idx.demonet.local -l rootAdmin -o /root/.globus/certificate-file
/usr/local/uvcdat/2.2.0/bin/esgscan_directory -project cordex -o test.map /esg/data/datapool1
/usr/local/uvcdat/2.2.0/bin/esgpublish --map ./test.map --project cordex --new-version `date +%Y%m%d` --service fileservice
/usr/local/uvcdat/2.2.0/bin/esgpublish --map ./test.map --project cordex --new-version `date +%Y%m%d` --noscan --thredds --publish --service fileservice

