#!/bin/bash
apt-get install net-tools -y

interface=$(ip route show | awk '/default/ {print $5}')

ip_address=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' > net

#net=$(sed 's/.$//' net)
#net=$(echo $net | cut -c 1-12)

echo "post-up /etc/network/ip-add-addresses" >> /etc/network/interfaces
echo "post-up /etc/network/ip-add-addresses" >> /etc/network/interfaces.d/50-cloud-init
echo "#!/bin/bash" >> /etc/network/ip-add-addresses
for ((i=2; i < 255; i++))
do
        echo ifconfig    $interface:$i $1.$i      netmask 255.255.255.0 up >> /etc/network/ip-add-addresses
done

chmod +x /etc/network/ip-add-addresses

