#!/bin/bash

#################################################################### 
# get_SSID_list.sh
#
# Author: MR
#
# Description: list all available WLAN SSIDs on a specified testbed node
#
# Input:       bash get_SSID_list.sh -a arg
#
# Example:     use "bash get_SSID_list.sh -a 101" to list WLAN SSIDs availble to node 101
#
####################################################################

#-------------------------------------------------------------------
help()
{
	echo ""
	echo "	### Bash script to list available wlan SSIDs on a specified testbed node ###"
	echo "	----------------------------------------------------------------------------"
	echo "	-a = specific address for the client"
	echo "	-n [OPTIONAL] = input the network interface (default: wlan0)"
	echo "	-u [OPTIONAL] = input client's username (default: ucanlab)"
	echo ""
	exit
}

#-------------------------------------------------------------------
# Set default parameters
network_interface=wlan0 # default
uname=ucanlab   # default
debug=0


#-------------------------------------------------------------------
# Get arguments and set appropriate parameters
while getopts 'ha:n:u:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		a)
			address=$OPTARG;;
		n)
			network_interface=$OPTARG;;
		u)
			uname=$OPTARG;;
		d)
			debug=1;;
	esac
done


#############################
#####     Main Code     #####
#############################
#-------------------------------------------------------------------

if [ $debug -gt 0 ]
then
	# for debugging... use -d flag
	echo ""
	echo "##### Debug Info: #####"
	echo "Address: 10.1.1.$address"
	echo "Interface: $network_interface"
	echo "UName: $uname"
	echo ""
	exit
fi

# SSH into node and list SSIDs. Remove all empty SSIDs, and print the second col (i.e., the SSID)
ssh $uname@10.1.1.$address sudo iw dev $network_interface scan | grep 'SSID:' | grep -v ': $' | awk '{print $2}'

