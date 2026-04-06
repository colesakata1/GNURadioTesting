#!/bin/bash

#################################################################### 
# get_mac.sh
#
# Author: Victoria Planchart
#
# Description: This script indicates the eth0, eth1 or wlan0 MAC address of the given node's IP addresses.
#
# Input: bash get_mac.sh -n (either eth0, eth1 or wlan0) -l (for specific nodes) or -r (for node's range)
# Example: for range from 101 to 115 type -r 101,115
#	   for specific nodes type -l 101,104,107,112,115
#	   for a specific network interface parameter, enter "-n" followed by either eth0, eth1 or wlan0. e.g: bash get_mac.sh -n eth1
#
####################################################################

#############################
#####     Functions     #####
#############################
#-------------------------------------------------------------------

help()
{
	echo ""
	echo "	### Bash script to get eth0, eth1, or wlan0 MAC addresses for testbed nodes ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-l = list of testbed node addresses (e.g., 'bash get_mac.sh -l 103,105,109')"
	echo "	-r = range of testbed node addresses (e.g., 'bash get_mac.sh -r 103,107')"
	echo "	-u [OPTIONAL] = client's username (e.g., '-u uname') (default: ucanlab)"
	echo "	-n [OPTIONAL] = node's network interface (e.g., '-n wlan0') (default: eth0)"
	echo "	                     (typically eth0, eth1, or wlan0 for RPis)"
	echo ""
	exit
}

#-------------------------------------------------------------------

# Creates array from command line inputs
addresses_list()
{
	IFS=','
	read -ra addresses <<< "$OPTARG"
}

#-------------------------------------------------------------------

# Parse input and create ip array from arg1 through arg2
addresses_range()
{
	IFS=','
	read -ra temp <<< "$OPTARG"
	index=0
	for (( i=${temp[0]}; i<=${temp[1]}; i++ ))
	do
		addresses[$index]=$i
		index=$((index+1))
	done
}

# function to setup the top row of the output
setup_col_titles()
{
	#TODO: Find a way to auto-adjust the column widths
	
	temp1="   Node  "	
	temp2="  ------ "
	
	# Keeping get_info structure in case we add optional info 
	temp1="$temp1     $network_interface MAC     "
	temp2="$temp2 -----------------"
	
	echo ""
	echo $temp1
	echo $temp2
}


#############################
#####   Setup Params    #####
#############################
#-------------------------------------------------------------------
# Set default parameters

uname=ucanlab # default
network_interface=eth0
debug=0

#-------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hl:r:u:n:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;
		u)
			uname=$OPTARG;;
		n)
			network_interface=$OPTARG;;
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
	echo "  ##### Debug Info: #####"
	echo "  Nodes: ${addresses[@]}"
	echo "  Interface: $network_interface"
	echo "  UName: $uname"
	echo ""
	exit
fi

# Call function to setup top row of output
setup_col_titles

# Loop through addresses and get the desired MAC address for each node
for i in "${addresses[@]}"
do

	# Put Pi number in first column
	temp="    $i"
	
	# if statement checks if interface exists (e.g., eth1 might not exist for non-server nodes)
	if ssh ucanlab@"10.1.1.$i" [ ! -d /sys/class/net/$network_interface ]
	then
		temp="$temp   Network Interface not found"
	else
		temp="$temp   $(ssh $uname@"10.1.1.$i" cat /sys/class/net/$network_interface/address)"
	fi
	
	# Print information for each Pi on a single Row
	echo $temp	
done

echo ""
