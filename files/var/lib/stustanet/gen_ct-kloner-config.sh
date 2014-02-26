#!/bin/sh

for iface in $(uci show wireless | egrep -o wireless.@wifi-iface\\[[[:alnum:]]\\] | sort | uniq); do
	# ATM we only know the values for WPA2, can be extended, if you know more ;)
	if ! [ $(uci get ${iface}.encryption) == psk2 ]; then
		echo "We can only export WPA2-Configurations for now, sorry!"
		break
	fi
	SSID=$(uci get ${iface}.ssid)
	WPAKEY=$(uci get ${iface}.key)
	UUID=$(uuidgen)
	cat > /tmp/${SSID}.wlan <<EOF
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>SSN-AP: ${SSID}</name>
	<SSIDConfig>
		<SSID>
			<name>${SSID}</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2PSK</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>networkKey</keyType>
				<protected>false</protected>
				<keyMaterial>${WPAKEY}</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
</WLANProfile>
EOF
done
