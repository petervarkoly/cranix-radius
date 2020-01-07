#!/bin/bash
# This script sends the MAC address and the user name to the oss-api.
# If the client was already registered the LoggedIn of the user will be set.
# If the client was not already registered the device will be registered.
# If the registration was successfully (OK) wait a litle bit that the DHCP can be restarted to get the new ip address.
# If the registration was not successfully the client stands in the ANON_DCHP range or braek the connection if SCHOOL_FORCE_REGISTER_DEVICE set yes
# Copyright Dipl.-Ing. Peter Varkoly <pvarkoly@cephalix.eu>
. /etc/sysconfig/schoolserver
if [ "$2" ]
then
	MAC=$( echo $2 |  tr "-" ":" )
	if [ "${SCHOOL_RADIUS_REGISTER_DEVICE}" = "yes" ]
	then
		OUT=$( curl -s -X PUT "http://localhost:9080/api/selfmanagement/addDeviceToUser/$MAC/$1"  )
		case "$OUT" in
			ALREADY-REGISTERED)
				curl -s -X PUT "http://localhost:9080/api/devices/loggedInUserByMac/$MAC/$1" &> /dev/null
				;;
			OK)
				curl -s -X PUT "http://localhost:9080/api/devices/loggedInUserByMac/$MAC/$1" &> /dev/null
				sleep 10
				;;
			*)
				if [ "${SCHOOL_FORCE_REGISTER_DEVICE}" = "yes" ]; then
					echo "Device can not be registered."
					exit 1
				else
					curl -s -X PUT "http://localhost:9080/api/devices/loggedInUserByMac/$MAC/$1" &> /dev/null
				fi
		esac
	else
		curl -s -X PUT "http://localhost:9080/api/devices/loggedInUserByMac/$MAC/$1" &> /dev/null

	fi
fi
exit 0

