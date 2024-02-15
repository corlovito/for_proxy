#!/bin/bash

ssh root@$1 "apt-get update -q"
ssh root@$1 "apt-get --yes install git"
#ssh root@$1 "cd /usr/src"
ssh root@$1 "git clone https://github.com/corlovito/for_proxy.git 3proxyinstall"
#ssh root@$1 "mkdir /usr/local/3proxy"
#scp ./files/*  root@$1:/usr/local/3proxy/
#scp ./deploy_network.sh  root@$1:/usr/src/
#scp ./deploy_debian9_2.sh  root@$1:/usr/src/
ssh root@$1 "chmod +x /root/3proxyinstall/deploy_network2.sh"
ssh root@$1 "apt update && apt install wget"
ssh root@$1 "/root/3proxyinstall/deploy_network2.sh $2"
ssh root@$1 "/root/3proxyinstall/deploy_debian9_2.sh"
ssh -p 24442 root@$1 "wget https://panel.spaceproxy.net/static/install_3proxy_client2.sh -O /tmp/install_3proxy_client2.sh"
ssh -p 24442 root@$1 "chmod +x /tmp/install_3proxy_client2.sh"
ssh -p 24442 root@$1 "/bin/bash /tmp/install_3proxy_client2.sh $3"
ssh -p 24442 root@$1 "reboot"