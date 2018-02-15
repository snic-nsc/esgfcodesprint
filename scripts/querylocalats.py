#!/usr/bin/env python

from pyesgf.security import ats
from pyesgf import __version__
from openid.yadis import discover
from lxml import etree
import socket,sys,argparse

socket.setdefaulttimeout(30)
QUERY_ISSUER='NULL'
cargs=dict()
cargs['CAINFO']='esgf-ca-bundle.crt'
aparser=argparse.ArgumentParser()
aparser.add_argument('openid',type=str,nargs='?',default='none')
aparser.add_argument('--file',type=str,nargs='?',default='none')
args=aparser.parse_args()
openid=args.openid
fname=args.file
if openid == 'none' and fname == 'none':
	sys.exit(-1)

print 'pyesgf version=%s'%__version__
def doLookup(openid,cargs):
	fail='notfound'
	try:
		discoverresult=discover.discover(openid,cargs)
	except:
		print "ConnectionError: failed to lookup %s"%(openid)
		raise
		sys.exit(-1)
	
	root=etree.XML(discoverresult.response_text)
	gotcha=0
	s_url='https://esg-idx.demonet.local/esgf-idp/saml/soap/secure/attributeService.htm'
	try:
		s=ats.AttributeService(s_url,QUERY_ISSUER)
	except:
		print fail
		raise
		sys.exit(-1)

	try:
		r=s.send_request(openid,['CORDEX_Commercial','CORDEX_Research','CMIP5 Research','CMIP5 Commercial','ext_pub'],cafile='esgf-ca-bundle.crt')
		#r=s.send_request(openid,['CORDEX_Commercial','CORDEX_Research','CMIP5 Research','CMIP5 Commercial','ext_pub'])
	except:
		print fail
		raise
		sys.exit(-1)
	res=r.get_attributes()
	if len(res) == 0:
		print "Not a member"
		sys.exit(-1)
	print res

if openid != 'none':
	doLookup(openid,cargs)
	sys.exit(0)

try:
	fp=open(fname,'r')
	flines=fp.readlines()
	fp.close()
except:
	print "File access error"
	sys.exit(-1)

for line in flines:
	openid=line.split('\n')[0]
	doLookup(openid,cargs)

