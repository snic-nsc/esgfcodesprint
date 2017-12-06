mkdir -p /root/.globus
export ESGINI=/esg/config/esgcet/esg.ini
myproxy-logon -s esg-idx.demonet.local -l rootAdmin -o /root/.globus/certificate-file
source /etc/esg.env
esgprep mapfile --mapfile test --project cordex /esg/data/datapool1
esgpublish --map ./test.map --project cordex --new-version `date +%Y%m%d` --service fileservice
esgpublish --map ./test.map --project cordex --new-version `date +%Y%m%d` --noscan --thredds --publish --service fileservice

