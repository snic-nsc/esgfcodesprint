mkdir -p /root/.globus
rm -rf /root/.globus/certificates
ln -s /etc/grid-security/certificates /root/.globus/certificates
export ESGINI=/esg/config/esgcet/esg.ini
export UVCDAT_ANONYMOUS_LOG=false
if [ "$HOSTNAME" = "esg-idx.demonet.local" -o "$HOSTNAME" = "esg-autoidx.demonet.local" ]; then
    myproxy-logon -s $HOSTNAME -l testpub -o /root/.globus/certificate-file
else
    myproxy-logon -s esg-idx.demonet.local -l testpub -o /root/.globus/certificate-file
fi
source /usr/local/conda/bin/activate esgf-pub
esgmapfile --mapfile test.map --project cordex /esg/data/datapool1
esgpublish --map mapfiles/test.map --project cordex --service fileservice
esgpublish --map mapfiles/test.map --project cordex --noscan --thredds
esgpublish --map mapfiles/test.map --project cordex --noscan --publish
