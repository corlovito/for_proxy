#!/bin/bash
apt-get install net-tools -y

ext_interface () {
    for interface in /sys/class/net/*
    do
        [[ "${interface##*/}" != 'lo' ]] && \
            ping -c1 -W2 -I "${interface##*/}" 1.1.1.1 >/dev/null 2>&1 && \
                printf '%s' "${interface##*/}" && return 0
    done
}

interface=$(ext_interface)
ip_address=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' > net

#net=$(sed 's/.$//' net)
#net=$(echo $net | cut -c 1-12)

echo "post-up /etc/network/ip-add-addresses" >> /etc/network/interfaces
echo "#!/bin/bash" >> /etc/network/ip-add-addresses
for ((i=2; i < 255; i++))
do
        echo ifconfig    $interface:$i $1.$i      netmask 255.255.255.0 up >> /etc/network/ip-add-addresses
done
