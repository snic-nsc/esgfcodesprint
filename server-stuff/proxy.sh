#!/bin/sh
#EXTIF="wlp2s0"
EXTIF="enp1s0"
INTIF="enp0s20f0u1"
INTIF2="wlp0s20f0u4"
VBOXNET='vboxnet0'
extip=`ip addr show $EXTIF|grep -w inet|awk '{print $2}'|cut -d '/' -f1`;
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
iptables -A INPUT -s 192.168.56.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.56.0/24 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.56.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 192.168.56.0/24 -p tcp --dport 3128 -j ACCEPT
iptables -A INPUT -s 192.168.56.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 68 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 20 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 3128 -j ACCEPT
iptables -A INPUT -s 192.168.3.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 192.168.3.0/24 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.3.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -s 192.168.3.0/24 -p tcp --dport 3128 -j ACCEPT
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -P OUTPUT ACCEPT
iptables -F OUTPUT 
iptables -P FORWARD DROP
iptables -F FORWARD 
iptables -t nat -F
iptables -A FORWARD -i $EXTIF -o $INTIF -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $EXTIF -o $INTIF2 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $EXTIF -o $VBOXNET -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A PREROUTING -t raw -p tcp --dport 21 -j CT --helper ftp
iptables -t nat -A PREROUTING -i $INTIF -p tcp --dport 80 -j DNAT --to $extip:3128
iptables -t nat -A PREROUTING -i $INTIF2 -p tcp --dport 80 -j DNAT --to $extip:3128
iptables -t nat -A PREROUTING -i $VBOXNET -p tcp --dport 80 -j DNAT --to $extip:3128
iptables -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT
iptables -A FORWARD -i $INTIF2 -o $EXTIF -j ACCEPT
iptables -A FORWARD -i $VBOXNET -o $EXTIF -j ACCEPT
iptables -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
