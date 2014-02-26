#!/bin/sh

IP="$(stustaip)"
echo $IP
GATE="$(echo $IP | sed -e "s/\\.[0-9]\{1,3\}\$/.254/")"
echo $GATE

uci set network.wan.proto=static
uci set network.wan.ipaddr="$IP"
uci set network.wan.netmask=255.255.255.0
uci set network.wan.gateway="$GATE"
uci set network.wan.dns="10.150.127.2 10.150.125.2"
uci commit network

/etc/init.d/network restart

exit 0

