#!/bin/sh

ctWLANKlonersrc="/opt/ssn_wlan-genearator/ct-wlan-kloner/0813-182.zip"

tmpdir=/tmp/wlancp-$(uuidgen)
mkdir -p ${tmpdir}

for iface in $(uci show wireless | egrep -o wireless.@wifi-iface\\[[[:alnum:]]\\] | sort | uniq); do
	# ATM we only know the values for WPA2, can be extended, if you know more ;)
	if ! [ $(uci get ${iface}.encryption) == psk2 ]; then
		echo "We can only export WPA2-Configurations for now, sorry!"
		break
	fi
	SSID=$(uci get ${iface}.ssid)
	WPAKEY=$(uci get ${iface}.key)
	UUID=$(uuidgen)
	BSSID=$(uci get wireless.$(uci get ${iface}.device).macaddr)
	cat > ${tmpdir}/${SSID}.nmconfig <<EOF
[connection]
id=${SSID}
uuid=${UUID}
type=802-11-wireless
timestamp=1387513203

[802-11-wireless]
ssid=${SSID}
mode=infrastructure
seen-bssids=${BSSID}
security=802-11-wireless-security

[802-11-wireless-security]
key-mgmt=wpa-psk
psk=${WPAKEY}

[ipv4]
method=auto
may-fail=false

[ipv6]
method=ignore
EOF
	chmod 600 ${tmpdir}/${SSID}.nmconfig

	cat > ${tmpdir}/${SSID}.mobileconfig <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>AutoJoin</key>
			<true/>
			<key>EncryptionType</key>
			<string>WPA</string>
			<key>HIDDEN_NETWORK</key>
			<false/>
			<key>Password</key>
			<string>${WPAKEY}</string>
			<key>PayloadDescription</key>
			<string>Konfiguration für StuStaNet-AP: ${SSID}</string>
			<key>PayloadDisplayName</key>
			<string>SSN-AP: ${SSID}</string>
			<key>PayloadIdentifier</key>
			<string>de.stustanet.wifi</string>
			<key>PayloadOrganization</key>
			<string>StuStaNet e. V.</string>
			<key>PayloadType</key>
			<string>com.apple.wifi.managed</string>
			<key>PayloadUUID</key>
			<string>${UUID}</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>ProxyType</key>
			<string>None</string>
			<key>SSID_STR</key>
			<string>${SSID}</string>
		</dict>
	</array>
	<key>PayloadDescription</key>
	<string>Profile description.</string>
	<key>PayloadDisplayName</key>
	<string>SSID</string>
	<key>PayloadIdentifier</key>
	<string>de.stustanet.wifi</string>
	<key>PayloadOrganization</key>
	<string>StuStaNet e. V.</string>
	<key>PayloadRemovalDisallowed</key>
	<false/>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>UUID</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
EOF
	cat > ${tmpdir}/${SSID}.wlan <<EOF
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
	unix2dos ${tmpdir}/${SSID}.wlan
done

unzip -d ${tmpdir} ${ctWLANKlonersrc} ctWLANKloner.exe
cp -r $(dirname ${ctWLANKlonersrc}) ${tmpdir}/
