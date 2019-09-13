#!/bin/bash
# This script sends the MAC address and the user name to the oss-api.
# If the client was already registered the LoggedIn of the user will be set.
# If the client was not already registered the device will be registered.
# If the registration was successfully (OK) wait a litle bit an break the connection
# to trigger a reconnection to get the new ip address.
# If the registration was not successfully the client stands in the ANON_DCHP range.
# Copiright Dipl.-Ing. Peter Varkoly <peter@varkoly.de>

if [ "$2" ]
then
	OUT=$( curl -s -X PUT "http://localhost:9080/api/selfmanagement/addDeviceToUser/$2/$1"  )
	case "$OUT" in
		ALREADY-REGISTERED)
		        curl -s -X PUT "http://localhost:9080/api/devices/loggedInUserByMac/$2/$1" &> /dev/null
			;;
		OK)
			sleep 10
			exit 1
			;;
	esac
fi
exit 0

