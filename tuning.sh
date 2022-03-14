#!/bin/bash

apt-get update


apt-get install net-tools -y


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

exit 0
