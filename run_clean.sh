#!/bin/bash

## Runs on SOM-EK Target

##
## Clean up after running demo's

echo 
echo "*** WIFI ***"
echo

ifconfig wlan0  down
# ifconfig wlan0  up

ip addr flush dev wlan0


echo
echo "Stop DHCP Server"
echo
/etc/init.d/S80dhcp-server stop


echo
echo "Kill DHCP Server"
echo
pidof udhcpc
killall udhcpc 
echo

echo
echo "Kill WPA Supplicant"
echo
pidof wpa_supplicant
killall wpa_supplicant
echo

echo
echo "Kill hostapd"
echo
pidof hostapd
killall hostapd
echo

echo 
echo "*** BLUETOOTH ***"
echo

echo 
echo "Killall hciattach"
echo
pidof hciattach
killall hciattach
echo

echo
echo "Kill bluetoothd"
echo
pidof bluetoothhd
killall bluetoothd
echo

 

