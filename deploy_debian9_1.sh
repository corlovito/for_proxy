#!/bin/bash

echo iptables-persistent iptables-persistent/autosave_v4 boolean true |  debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true |  debconf-set-selections
apt-get -y install iptables-persistent
iptables -I OUTPUT -p tcp --match multiport --dports 25,465,587 -j DROP
netfilter-persistent save

/usr/src/3proxyinstall/deploy_network.sh
/usr/src/3proxyinstall/deploy_debian9_2.sh
sleep 300
wget https://panel.spaceproxy.net/static/install_3proxy_client2.sh -O /tmp/install_3proxy_client2.sh
chmod +x /tmp/install_3proxy_client2.sh
/bin/bash /tmp/install_3proxy_client2.sh $KEY_SERVER
