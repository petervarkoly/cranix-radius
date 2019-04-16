#!/bin/bash

if [ "$2" ]
then
        curl -s -X PUT "http://localhost:9080/api/devices/loggedInUserByMac/$2/$1" &> /dev/null
fi
exit 0

