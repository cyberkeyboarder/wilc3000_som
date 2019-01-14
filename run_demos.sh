#!/bin/bash

## Runs on SOM-EK Target

## Should run 'run_clean.sh' before any demo.

## Ex. 	DEMO # 1 - Station Mode (Connect to AP)
## $ run_clean.sh
## $ run_demos.sh 1

## Ex.	DEMO # 2 - WIFI AP MODE (Soft AP)
## $ run_clean.sh
## $ run_demos.sh 2

## Ex.	DEMO # 3 - BLUETOOTH 
## $ run_clean.sh
## $ run_demos.sh 3




# ------------------------------------------------------------------------------
# SYSTEM CONFIGURATION 
# ------------------------------------------------------------------------------

function system_config()
{
	echo
	echo "-----------------------------------------------------------"
	echo "* SYSTEM CONFIGURATION - START "
	echo "-----------------------------------------------------------"
	echo

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls='ls --color=auto'
		#alias dir='dir --color=auto'
		#alias vdir='vdir --color=auto'

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi

	# colored GCC warnings and errors
	#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

	# some more ls aliases
	alias ll='ls -ahlF'
	alias la='ls -A'
	alias l='ls -CF'

	echo
	echo "-----------------------------------------------------------"
	echo "* SYSTEM CONFIGURATION - COMPLETE "
	echo "-----------------------------------------------------------"
	echo

}

# ------------------------------------------------------------------------------
# DEMO # 1 - Station Mode (Connect to AP)
# ------------------------------------------------------------------------------

function demo_1()
{

	echo
	echo "-----------------------------------------------------------"
	echo "* DEMO # 1 - WIFI STATION MODE (CONNECT TO AP) - START "
	echo "-----------------------------------------------------------"
	echo

	# Stop debug messages
	dmesg -n 1

	echo
	echo "-----------------------------------------------------------"
	echo "* Check if \"wlan0\" is active "
	echo "-----------------------------------------------------------"
	echo
	sleep 2
	ifconfig wlan0
	sleep 5

	echo
	echo "-----------------------------------------------------------"
	echo "* RUN WPA2 Supplicant "
	echo 
	echo "  Note: Rfkill, a tool for enabling and disabling wireless "
	echo "  devices. Most of the time the kernel does not have rfkill"
	echo "  enabled in it. So there is no /dev/rfkill file present,"
	echo "  and rfkill command will give errors like"
	echo "  rfkill: Cannot open RFKILL control device"
	echo "  * Control device here means /dev/rfkill"
	echo "-----------------------------------------------------------"
	echo
	echo "wpa_supplicant -Dnl80211 -iwlan0 -c /etc/wpa_supplicant.conf &"
	sleep 2
	wpa_supplicant -Dnl80211 -iwlan0 -c /etc/wpa_supplicant.conf &
	sleep 5


	echo
	echo "-----------------------------------------------------------"
	echo "* DHCP SERVER "
	echo "-----------------------------------------------------------"
	echo
	sleep 2
	echo "udhcpc -i wlan0 &"
	udhcpc -i wlan0 &
	sleep 5

	echo
	echo "-----------------------------------------------------------"
	echo "* PING (x6) GOOGLE PUBLIC DNS SERVER "
	echo "-----------------------------------------------------------"
	echo
	#echo "ping -c6 8.8.8.8"
	#ping 8.8.8.8


	echo
	echo "-----------------------------------------------------------"
	echo "* DEMO # 1 - WIFI STATION MODE (CONNECT TO AP) - COMPLETE "
	echo "-----------------------------------------------------------"
	echo

}

# ------------------------------------------------------------------------------
# DEMO # 2 - WIFI AP MODE (Soft AP)
# ------------------------------------------------------------------------------

function demo_2()
{

	echo
	echo "-----------------------------------------------------------"
	echo "* DEMO # 2 - WIFI AP MODE - START "
	echo "-----------------------------------------------------------"
	echo

	# Stop debug messages
	dmesg -n 1
	
	echo
	echo "-----------------------------------------------------------"
	echo "* Check WILC3000 Drivers"
	echo "-----------------------------------------------------------"
	echo
	sleep 2
	echo "lsmod"
	lsmod
	echo
	ifconfig wlan0
	sleep 3

	echo		
	echo "-----------------------------------------------------------"
	echo "* Start hostdap daemon "
	echo "-----------------------------------------------------------"
	echo
	echo "hostapd /etc/wilc_hostapd_open.conf -B &"
	sleep 2
	hostapd /etc/wilc_hostapd_open.conf -B &
	sleep 4

	echo		
	echo "-----------------------------------------------------------"
	echo "* Check if link is UP "
	echo "-----------------------------------------------------------"
	echo
	sleep 2
	ifconfig wlan0
	sleep 3

	echo		
	echo "-----------------------------------------------------------"
	echo "* Assign IP address "
	echo "-----------------------------------------------------------"
	echo
	echo "ifconfig wlan0 192.168.0.1"
	ifconfig wlan0 192.168.0.1
	sleep 3

	echo		
	echo "-----------------------------------------------------------"
	echo "* Start DHCP Server "
	echo "-----------------------------------------------------------"
	echo
	echo "/etc/init.d/S80dhcp-server start"
	/etc/init.d/S80dhcp-server start
	sleep 4

	echo		
	echo "-----------------------------------------------------------"
	echo "* NOTE: FROM MOBILE PHONE - PING assigned IP"
	echo "*       Observe DHCP Server == running ..."
	echo "* "
	echo "* DEMO # 2 - WIFI AP MODE - COMPLETE "
	echo "-----------------------------------------------------------"
	echo

	ps aux | grep dhcpd 

	ifconfig wlan0 
	ifconfig wlan0 | grep -i UP
	ifconfig wlan0 | grep -i addr:192
	echo
	iw wlan0 info

	#/etc/init.d/S80dhcp-server stop
	#ps aux | grep dhcpd 
 
}


# ------------------------------------------------------------------------------
# DEMO # 3 - BLUETOOTH 
# ------------------------------------------------------------------------------

function demo_3()
{

	echo
	echo "-----------------------------------------------------------"
	echo "* DEMO # 3 - BLUETOOTH - START "
	echo "-----------------------------------------------------------"
	echo

	# Stop debug messages
	dmesg -n 1

	echo
	echo "-----------------------------------------------------------"
	echo " Initialize BLE"
	echo "-----------------------------------------------------------"
	echo

	echo "BT_POWER_UP > /dev/wilc_bt"
	echo BT_POWER_UP > /dev/wilc_bt
	sleep 4

	echo "BT_DOWNLOAD_FW > /dev/wilc_bt"
	echo BT_DOWNLOAD_FW > /dev/wilc_bt
	sleep 4

	echo "BT_FW_CHIP_WAKEUP > /dev/wilc_bt"
	echo BT_FW_CHIP_WAKEUP > /dev/wilc_bt
	sleep 4

	echo "BT_FW_CHIP_ALLOW_SLEEP > /dev/wilc_bt"
	echo BT_FW_CHIP_ALLOW_SLEEP > /dev/wilc_bt
	sleep 4
	 
	echo
	echo "-----------------------------------------------------------"
	echo "* HCIATTACH (Host Controller Interface)"
	echo "  - Attach UART HCI to BlueZ Stack"
	echo "-----------------------------------------------------------"
	echo

	echo "hciattach ttyS2 any 115200 noflow"
	hciattach ttyS2 any 115200 noflow
	sleep 4

	echo "hciconfig -a"
	hciconfig -a
	sleep 4

	echo "hciconfig hci0 up"
	hciconfig hci0 up
	sleep 4

	echo
	echo "-----------------------------------------------------------"
	echo "* SYMBOLIC LINK for bluetoothd "
	echo "-----------------------------------------------------------"
	echo
	
	echo "ln -svf /usr/libexec/bluetooth/bluetoothd /usr/sbin "
	ln -svf /usr/libexec/bluetooth/bluetoothd /usr/sbin
	sleep 1

	echo 
	echo "-----------------------------------------------------------"
	echo "* Start the Bluetooth daemon"
	echo "-----------------------------------------------------------"
	echo

	echo "bluetoothd -n &"
	bluetoothd -n &
	sleep 4

	echo
	echo "-----------------------------------------------------------"
	echo "* Bluetooth Control Tool"
	echo "-----------------------------------------------------------"
	echo

	bluetoothctl

}


 
# Check only first command line arg.
if [ -z $1 ]
then
	echo "Need one of these as a command line parameter: cfg, 1, 2, 3"
	echo
  	exit
elif [ -n $1 ]
then
  demo=$1
fi

# use case statement to make decision for rental
case $demo in
	"cfg") 
		system_config
		;;
   	"1")
		demo_1
		;;
   	"2") 
		demo_2
		;;
   	"3") 
	   demo_3
		;;
	*) 
		echo "< unrecognized >"	
		echo "Need one of these as a command line parameter: cfg, 1, 2, 3"
		;;
esac

