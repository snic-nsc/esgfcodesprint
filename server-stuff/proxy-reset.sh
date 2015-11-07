#!/bin/bash
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -A INPUT -j ACCEPT
iptables -P OUTPUT ACCEPT
