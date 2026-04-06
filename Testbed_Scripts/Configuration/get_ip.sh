#!/bin/bash

#################################################################### 
# get_wlan_ip.sh
#
# Author: Victoria Planchart
#
# Description: This script indicates the wlan0 or eth0 IP address of the given nodes.
#
# Input: bash get_ip.sh -i 192 or 10 -r 101,115 (this will get the IPs of the nodes from 101 to 115)
#	 bash get_ip.sh -i 192 or 10 -l 101,103,105,107,111 (for specific node's IP)
#
# **For Help, enter -h**
#
####################################################################

#############################
#####     Functions     #####
#############################
#-------------------------------------------------------------------

help()
{
	echo ""
	echo "	### Bash script to get eth0 or wlan0 IP addresses for testbed nodes ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-r = range of testbed node addresses (e.g., bash get_ip.sh -r 103,107)"
	echo "	-l = list of testbed node addresses (e.g., bash get_ip.sh -l 103,105,109)"
	echo "	-u [OPTIONAL] = client's username (e.g., '-u uname') (default: ucanlab)"
	echo "	-n [OPTIONAL] = input '-n 192' for the wlan0 IP address (test network)"
	echo "	                   or '-n 10' for the eth0 IP address (control network) (default: 192)"
	echo ""
	exit
}

#-------------------------------------------------------------------

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
	#------------------
	if (( $net_interface == 192 ))
	then
		temp1="$temp1      Test IP     "
		temp2="$temp2 -----------------"
	else
		temp1="$temp1    Control IP    "
		temp2="$temp2 -----------------"	
	fi
	
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
net_interface=192
debug=0

#-------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hr:l:u:n:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		r)
			addresses_range;;
		l)
			addresses_list;;
		u)
			uname=$OPTARG;;
		n)
			net_interface=$OPTARG;;
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
	echo "  Interface: $net_interface"
	echo "  UName: $uname"
	echo ""
	exit
fi

# Call function to setup top row of output
setup_col_titles

for i in "${addresses[@]}"
do

	# Put Pi number in first column
	temp="    $i    $(ssh $uname@"10.1.1.$i" ip addr | grep "inet $net_interface" | awk '{print $2}')"
	
	# Print information for each Pi on a single Row
	echo $temp	
	
	#OLD METHOD
	#ssh $uname@"10.1.1.$i" ifconfig wlan0 | grep "inet" | grep "broadcast" | awk '{print $2}'
done

echo ""
