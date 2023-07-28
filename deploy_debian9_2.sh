#!/bin/bash
ext_interface () {
    for interface in /sys/class/net/*
    do
        [[ "${interface##*/}" != 'lo' ]] && \
            ping -c1 -W2 -I "${interface##*/}" 8.8.8.8 >/dev/null 2>&1 && \
                printf '%s' "${interface##*/}" && return 0
    done
}

interface=$(ext_interface)

apt-get update
apt-get -y install gcc g++ git make bc pwgen vlan zip unzip
#sed -i 's/#22/24442/'  /etc/ssh/sshd_config
echo port 24442 >> /etc/ssh/sshd_config
service sshd restart
apt install -y gcc make cmake
cd /root
rm -rf /root/3proxy
git clone https://github.com/z3apa3a/3proxy
cd 3proxy
ln -s Makefile.Linux Makefile
make
make install-chroot-dir install-bin
apt install curl -y
chmod +x /usr/local/3proxy/run.sh
chmod +x /usr/local/3proxy/run_proxyline.sh
chmod +x /usr/local/3proxy/config_listener.sh
chmod +x /usr/local/3proxy/archiver.sh
chmod +x /etc/network/ip-add-addresses
mkdir -p /var/log/3proxy/archives
apt install psmisc -y
#nohup /usr/local/3proxy/config_listener.sh &
#apt install sudo -y
apt-get install net-tools -y

#PASS=$(date +%s | sha256sum | base64 | head -c 12 ; echo)
#echo $PASS > /usr/local/3proxy/pass.txt
#adduser proxyuser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
#echo "proxyuser:$PASS" | sudo chpasswd

#echo "proxyuser  ALL=(ALL:ALL) ALL" >> /etc/sudoers

 cd /usr/local/3proxy
 touch 3proxy.monitor
 apt-get install ntpdate -y
 ntpdate time.nist.gov 
# chown -R proxyuser:proxyuser .
 echo  "
DefaultLimitDATA=infinity
DefaultLimitSTACK=infinity
DefaultLimitCORE=infinity
DefaultLimitRSS=infinity
DefaultLimitNOFILE=102400
DefaultLimitAS=infinity
DefaultLimitNPROC=10240
DefaultLimitMEMLOCK=infinity
" >> /etc/systemd/system.conf 
 echo  "
* soft nofile 100000
* hard nofile 100000
root - nofile 100000
# End of file
" >>  /etc/security/limits.conf

(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/3proxy/archiver.sh") | crontab -; (crontab -l 2>/dev/null; echo "0 0 * * * ( killall config_listener.sh; nohup /usr/local/3proxy/config_listener.sh >> /root/listener.out 2>&1 &)") | crontab -; (crontab -l 2>/dev/null; echo "0 5 * * * /usr/local/3proxy/run_proxyline.sh") | crontab -; (crontab -l 2>/dev/null; echo "0 */3 * * * ( sync; echo 3 > /proc/sys/vm/drop_caches; )") | crontab -; (crontab -l 2>/dev/null; echo "00 1 * * * ntpdate time.nist.gov") | crontab -




touch /etc/rc.local
chmod +x /etc/rc.local
touch /etc/systemd/system/rc-local.service

tee  /etc/systemd/system/rc-local.service << EOF
[Unit]
 Description=/etc/rc.local Compatibility
  ConditionPathExists=/etc/rc.local
   
  [Service]
   Type=forking
    ExecStart=/etc/rc.local start
     TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99
 
[Install]
 WantedBy=multi-user.target
EOF

tee  /etc/rc.local << EOF
#!/bin/bash
ifconfig $interface txqueuelen 10000
exit 0
EOF

systemctl enable rc-local
systemctl start rc-local
tee  /etc/sysctl.conf << EOF

vm.max_map_count=1031062
kernel.pid_max=103102
kernel.threads-max=200000
fs.file-max=1000000
net.core.netdev_max_backlog=10000
net.core.somaxconn=600000
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 720000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 7
net.ipv4.tcp_keepalive_intvl = 30
net.core.wmem_max = 33554432
net.core.rmem_max = 33554432
net.core.rmem_default = 8388608
net.core.wmem_default = 4194394
net.ipv4.tcp_rmem = 4096 8388608 16777216
net.ipv4.tcp_wmem = 4096 4194394 16777216
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.icmp_echo_ignore_all=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.all.rp_filter=0
EOF


#apt-get install linux-image-4.9.0-0.bpo.11-amd64
exit 0



