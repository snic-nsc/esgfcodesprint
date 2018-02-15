* certandchainlookup.sh: looks up certficate and chain. Arguments: hostname and port; 
````
bash certchainlookup.sh esg-dn1.nsc.liu.se 443    
````
* eggs: contains eggfile for esgf-pyclient, with support for specification of cafile in call to ats. Needed for querylocalats.py. 
* install-prereqs.sh: installs some prerequisite RPMs.    
* querylocalats.py: looks up local attribute services running on esg-idx.demonet.local. Needs modified esgf-pyclient (to be installed from egg present in eggs directory), and requires that local attribute services have been setup   
````
python querylocalats.py https://esg-idx.demonet.local/esgf-idp/openid/testpub
````
* reelouthashes.sh: dumps hash, issuer hash and subject of certificates/cert bundles.    
* rinseandrepeat.sh: script to do esg-purge and refetch and execute bootstrap files. Requires an esg-autoinstall.conf file present locally.    
* spitmac.sh: outputs hardware address (MAC address) of NICs.
* stripcert.sh: script to output only certificate, from a mix of certificate and plain-text/debug output. eg
````
openssl s_client -showcerts -connect esg-dn1.nsc.liu.se:443 </dev/null 2>/dev/null|bash stripcert.sh
````
* usermgmt.py: script to setup local publication groups, and create publisher users. 
