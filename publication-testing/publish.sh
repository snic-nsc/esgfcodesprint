mkdir -p /root/.globus
export ESGINI=/esg/config/esgcet/esg.ini
myproxy-logon -s esg-idx.demonet.local -l rootAdmin -o /root/.globus/certificate-file
source /usr/local/conda/bin/activate esgf-pub
esgprep mapfile --mapfile test.map --project cordex /esg/data/datapool1
esgpublish --map mapfiles/test.map --project cordex --new-version `date +%Y%m%d` --service fileservice
esgpublish --map mapfiles/test.map --project cordex --new-version `date +%Y%m%d` --noscan --thredds --service fileservice
