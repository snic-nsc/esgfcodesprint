mkdir -p /root/.globus
export ESGINI=/esg/config/esgcet/esg.ini
myproxy-logon -s esg-idx.demonet.local -l testpub -o /root/.globus/certificate-file
source /usr/local/conda/bin/activate esgf-pub
esgmapfile --mapfile test.map --project cordex /esg/data/datapool1
esgpublish --map mapfiles/test.map --project cordex --service fileservice
esgpublish --map mapfiles/test.map --project cordex --noscan --thredds --publish --service fileservice
