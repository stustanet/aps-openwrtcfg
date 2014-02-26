#!/bin/sh

for iface in $(uci show wireless | egrep -o wireless.@wifi-iface\\[[[:alnum:]]\\] | sort | uniq); do
	SSID=$(uci get ${iface}.ssid)
	WPAKEY=$(uci get ${iface}.key)
	UUID=$(uuidgen)
	cat > /tmp/${SSID}.mobileconfig <<EOF
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
done
