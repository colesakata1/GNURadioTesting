#!/bin/bash

#################################################################### 
# set_params.sh
#
# Author: Victoria Planchart (Original)
#
# Description: Script to change parameters on specified Pi(s)
#
# Input: bash set_params_pi.sh -l <node number> -p <power value>
#
####################################################################

#############################
#####     Functions     #####
#############################
#-------------------------------------------------------------------
help()
{
	echo ""
	echo "	### Bash script to set parameters for a given testbed node ###"
	echo "	----------------------------------------------------------------------------"
	echo "	-l = list of testbed node addresses (e.g., 'bash set_params_pi.sh -l 103,105,109')"
	echo "	-r = range of testbed node addresses (e.g., 'bash set_params_pi.sh -r 103,107')"
	echo "	-p = Set wifi power for specied nodes (e.g., 'bash set_params_pi.sh -l 101 -p 20')"
	echo "	-u [OPTIONAL] = input client's username (default: ucanlab)"
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

#############################
#####   Setup Params    #####
#############################
#-------------------------------------------------------------------
# Set default parameters
uname=ucanlab   # default

#-------------------------------------------------------------------
# Get arguments and set appropriate parameters
while getopts 'hl:r:p:' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;		
		p)
			power=$OPTARG;;
	esac
done

#############################
#####     Main Code     #####
#############################
#-------------------------------------------------------------------

for i in "${addresses[@]}"
do
	ssh $uname@10.1.1.$i sudo iwconfig wlan0 txpower $power
done
