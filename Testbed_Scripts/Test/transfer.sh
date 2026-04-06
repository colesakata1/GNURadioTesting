#!/bin/bash

#####################################################################################
# transfer.sh
#
# Author: Victoria Planchart
#
# Description: This script transfers iperf results files from the RPis to the TC.
#		It can take a range of clients, or specific number of clients.
#
# Input: for range: bash transfer.sh -r 103,107 -f <folder name>
#        specific: bash transfer.sh -l 101,103 -f <folder name>, enter, and then enter the values
#
#####################################################################################

#############################
#####     Functions     #####
#############################
#------------------------------------------------------------------------------------

help()
{
	echo ""
	echo "	### Bash script to transfer results from RPi nodes to TC ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-l = list of client node addresses (e.g., 'bash transfer.sh -l 103,105,109')"
	echo "	-r = range of client node addresses (e.g., 'bash transfer.sh -r 103,107')"
	echo "	-f = input the folder name in the pis to be transferred"
	echo "	-u [OPTIONAL] = input client's username if the deffault one (ucanlab) is not used"
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
#---------------------------------------------------------------------------------------------
# Set default parameters

uname=ucanlab # default
debug=0

#------------------------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hl:r:f:u:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;
		f)
			folder_name=$OPTARG;;
		u)
			uname=$OPTARG;;
		d)
			debug=1;;			
	esac
done

# Setup Pi's top directory after input, in case Pi username is not default
top_dir=/home/$uname/ucan_TB/TB_Results
top_dir_TC=~/ucan_TB/TB_Results

#############################
#####     Main Code     #####
#############################
#------------------------------------------------------------------------------------
if [ $debug -gt 0 ]
then
	# for debugging... use -d flag
	echo ""
	echo "  ##### Debug Info: #####"
	echo "  Nodes: ${addresses[@]}"
	echo "  Results Folder: $top_dir/$folder_name"
	echo "  Pi Folder: $top_dir/${folder_name}_piXXX"
	echo "  UName: $uname"
	echo ""
	exit
fi


if [ ! -d $top_dir_TC/${folder_name} ] 
then
	mkdir -p $top_dir_TC/${folder_name}
	
	for i in "${addresses[@]}"
	do
		scp -pr $uname@10.1.1.$i:$top_dir/${folder_name}_pi$i $top_dir_TC/${folder_name}
	done

else
	echo "Directory already exists on the TC"
fi
