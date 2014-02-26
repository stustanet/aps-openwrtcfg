#!/bin/sh 

uci set wireless.@wifi-iface[-1].ssid="SSNUAP_$(pwgen -v 5 1)"
uci set wireless.@wifi-iface[-1].key="$(pwgen -v -c -n 8 1)"
uci commit wireless
echo -n "Name: " > /www/wlan.txt
uci get wireless.@wifi-iface[-1].ssid >> /www/wlan.txt
echo -n "Password: " >> /www/wlan.txt
uci get wireless.@wifi-iface[-1].key >> /www/wlan.txt

wifi
exit 0


