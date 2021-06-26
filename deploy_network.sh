#!/bin/bash
apt-get install net-tools -y

ext_interface () {
    for interface in /sys/class/net/*
    do
        [[ "${interface##*/}" != 'lo' ]] && \
            ping -c1 -W2 -I "${interface##*/}" 8.8.8.8 >/dev/null 2>&1 && \
                printf '%s' "${interface##*/}" && return 0
    done
}

interface=$(ext_interface)

echo "post-up /etc/network/ip-add-addresses" >> /etc/network/interfaces
echo "#!/bin/bash" >> /etc/network/ip-add-addresses
for ((i=3; i < 253; i++))
do
        echo ifconfig    $interface:$i $1.$i      netmask 255.255.255.0 up >> /etc/network/ip-add-addresses
done
