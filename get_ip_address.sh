#!/bin/bash

a="`netstat -i | cut -d' ' -f1 | grep eth0`";
b="`netstat -i | cut -d' ' -f1 | grep venet0:0`";

if [ "$a" == "eth0" ]; then
  echo "eth0 found"
  ip="`/sbin/ifconfig eth0 | awk -F':| +' '/inet addr/{print $4}'`";
elif [ "$b" == "venet0:0" ]; then
  echo "venet found"
  ip="`/sbin/ifconfig venet0:0 | awk -F':| +' '/inet addr/{print $4}'`"; 
fi

echo $ip;
