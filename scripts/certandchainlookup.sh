#!/bin/bash
host=$1
port=$2
timeout 10 openssl s_client -showcerts -connect $host:$port </dev/null 2>&1|bash stripcert.sh >chain
timeout 10 openssl s_client -connect $host:$port </dev/null 2>&1|bash stripcert.sh >cert
openssl verify -verbose -purpose sslserver -CAfile chain cert
