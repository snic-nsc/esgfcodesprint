#!/usr/bin/python

import argparse,socket
import psycopg2
import sys
import readline
from collections import OrderedDict


aparser=argparse.ArgumentParser()
aparser.add_argument('--enable-extpub', type=str, default=None, help='requires the hostname of the idp')
aparser.add_argument('--disable-extpub', type=str, default=None, help='requires the hostname of the idp')
aparser.add_argument('--enable-localgroups', type=str, default='none', nargs='?', help='enables local publication groups')
args=aparser.parse_args()
enablepub=args.enable_extpub
disablepub=args.disable_extpub
enablelocalpub=args.enable_localgroups

if len(sys.argv) == 1:
    aparser.print_help()
    sys.exit(0)

with open('/esg/config/.esg_pg_pass') as passfile:
    passwd=passfile.readline().split('\n')[0]
try:
    conn=psycopg2.connect("dbname='esgcet' user='dbsuper' password='%s'"%(passwd))
except:
    print "Unable to connect"
    exit(-1)

cur=conn.cursor()

if enablepub != None:
    while True:
        choice=raw_input("You entered \"%s\" as the value for the idp. Is this correct?(Y/n) "%enablepub)
        if choice == 'N' or choice == 'n':
            enablepub=raw_input("Enter the value of the idp server, e.g esg-idx.demonet.local\n")
        else:
            break
    qperm="insert into esgf_security.permission (user_id,group_id,role_id,approved) values ( (select u.id from esgf_security.user u where u.openid='https://%s/esgf-idp/openid/testpub'), (select g.id from esgf_security.group g where g.name='ext_pub'), (select r.id from esgf_security.role r where r.name='user'), True )"%(enablepub)
    qaddgp="insert into esgf_security.group(name,description,visible,automatic_approval) values ('ext_pub','external publishers group', False, False)"
    qadduser="insert into esgf_security.user(firstname,lastname,email,username,password,openid,organization,city,country) values('Publisher','Tester','pt@example.org','testpub','$1$GnNDs7Ed$M5hLjBHVOTJGZv4TcNCFU0','https://%s/esgf-idp/openid/testpub','ABC','Linkoping','SWEDEN')"%enablepub

    try:
        cur.execute(qaddgp)
        conn.commit()
    except:
        conn.rollback()
    try:
        cur.execute(qadduser)
        conn.commit()
    except:
        conn.rollback()
    try:
        cur.execute(qperm)
        conn.commit()
        print 'Added user and adjusted permissions accordingly'
    except:
        print 'No changes needed'
        sys.exit(0)
    sys.exit(0)

if enablelocalpub != 'none':
    creategroups=OrderedDict()
    creategroups['CORDEX_Research']='local CORDEX Research Group'
    creategroups['CORDEX_Commercial']='local CORDEX Commercial'
    creategroups['CMIP5 Research']='local CMIP5 Research Group'
    creategroups['CMIP5 Commercial']='local CMIP5 Commercial Group'
    
    for key,val in creategroups.iteritems():
        opstr="insert into esgf_security.group(name,description,visible,automatic_approval) values ('%s','%s', True, True)"%(key,val)
        try:
            cur.execute(opstr)
            conn.commit()
            print 'Successfully added local group for %s data publication'%(key)
        except:
            print 'Local group for %s data publication already present'%(key)
            conn.rollback()
    print 'All local groups now present'
    sys.exit(0)

if disablepub != None:
    while True:
        choice=raw_input("You entered \"%s\" as the value for the idp. Is this correct?(Y/n) "%disablepub)
        if choice == 'N' or choice == 'n':
            disablepub=raw_input("Enter the value of the idp server, e.g esg-idx.demonet.local\n")
        else:
            break
    try:
        cur.execute("select id from esgf_security.user where openid = 'https://%s/esgf-idp/openid/testpub'"%disablepub)
        records=cur.fetchall()
        id=int(records[0][0])
        querystr="select id from esgf_security.group where name = 'ext_pub'"
        cur.execute(querystr)
        records=cur.fetchall()
        gp=records[0][0]
    
        querystr="delete from esgf_security.permission where user_id = %d and group_id = %d"%(id,gp)
        cur.execute(querystr)
        cur.execute("delete from esgf_security.user where openid = 'https://%s/esgf-idp/openid/testpub'"%disablepub)
        conn.commit()
        print 'Deleted user account and publication permissions for openid https://%s/esgf-idp/openid/testpub'%(disablepub)
    except:
        print 'Already deleted/not found'
        sys.exit(0)
