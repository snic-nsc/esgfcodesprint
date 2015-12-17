#!/bin/sh
EXTIF="enp0s20u1"
INTIF="eno1"
/sbin/depmod -a
/sbin/modprobe ip_tables
/sbin/modprobe ip_conntrack
/sbin/modprobe ip_conntrack_ftp
/sbin/modprobe ip_conntrack_irc
/sbin/modprobe iptable_nat
/sbin/modprobe ip_nat_ftp
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/ip_dynaddr
iptables -P INPUT DROP
iptables -F INPUT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT 
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 68 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -P OUTPUT ACCEPT
iptables -F OUTPUT 
iptables -P FORWARD DROP
iptables -F FORWARD 
iptables -t nat -F
iptables -A FORWARD -i $EXTIF -o $INTIF -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
iptables -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
