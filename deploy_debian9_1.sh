#!/bin/bash

echo iptables-persistent iptables-persistent/autosave_v4 boolean true |  debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true |  debconf-set-selections
apt-get -y install iptables-persistent
iptables -I OUTPUT -p tcp --match multiport --dports 25,465,587 -j DROP
netfilter-persistent save

/usr/src/3proxyinstall/deploy_network2.sh
/usr/src/3proxyinstall/deploy_debian9_2.sh
