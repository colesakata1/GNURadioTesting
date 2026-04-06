#!/bin/bash

#################################################################### 
# sdr_status.sh
#
# Author: MR
#
# Description: This script checks for active python scripts
#
# Input: 
#
# **For Help, enter -h**
#
####################################################################
#############################
#####     Functions     #####
#############################
#---------------------------------------------------------------------------------------------

help()
{
	echo ""
	echo "	### Bash script to check for active python scripts at specified nodes ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-l = list of client node addresses (e.g., 'bash sdr_tone_start.sh -l 103,105,109')"
	echo "	-r = range of client node addresses (e.g., 'bash sdr_tone_start.sh -r 103,107')"
	echo "	-f = check for python3 processes (to show flowgraph status)"
	echo "	-p = check for xmlrpc and zmq ports (at defined ports)"
	echo "	-k [OPTIONAL] = kill processes with specified PID at corresponding nodes"
	echo "	                  (e.g., bash sdr_status.sh -l 101,014 -k 1234,1235) "
	echo "	                  CAUTION: can kill other processes if incorrect pid is given"
	echo "	-u [OPTIONAL] = input client's username if the deffault one (ucanlab) is not used"
	echo ""
	exit
}

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
addresses_list()
{
	IFS=','
	read -ra my_addresses <<< "$OPTARG"
}

#---------------------------------------------------------------------------------------------
# Parse input and create ip array from arg1 through arg2
addresses_range()
{
	IFS=','
	read -ra temp <<< "$OPTARG"
	index=0
	for (( i=${temp[0]}; i<=${temp[1]}; i++ ))
	do
		my_addresses[$index]=$i
		index=$((index+1))
	done
}


#############################
#####   Setup Params    #####
#############################
#---------------------------------------------------------------------------------------------
# Set default parameters

uname=ucanlab # default
fg_status=0
port_status=0
kill_procs=0
debug=0

tx_xmlrpc_port=':8080'
rx_xmlrpc_port=':8081'
zmq_port=':55555'

#---------------------------------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hl:r:fpk:u:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;
		f)
			fg_status=1;;
		p)
			port_status=1;;
		k)
			kill_procs=1;
			IFS=','
			read -ra pids <<< "$OPTARG";;
		u)
			uname=$OPTARG;; # in case the username is not the default one, use this flag to user another username
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
	echo "  Nodes: ${my_addresses[@]}"
	echo "  Port Check: $port_status (TX xml: $tx_xmlrpc_port, RX xml: $rx_xmlrpc_port, ZMQ: $zmq_port )"
	echo "  Flowgraph Check: $fg_status"
	echo "  Kill Processes: $kill_procs"
	echo "  PIDs: ${pids[@]}"
	echo "  UName: $uname"
	echo ""
	exit
fi	


#############################
#####     Main Code     #####
#############################
#------------------------------------------------------------------------------------

i=0
while [[ $i -lt ${#my_addresses[@]} ]]; do # loop through number of nodes
	# get desired values from list 
	my_addr=${my_addresses[$i]}
	my_pid=${pids[$i]}
	
	echo "  ------------"
	echo "  Node $my_addr "
	
	if (( $port_status == 1 ))
	then
		ssh $uname@10.1.1.$my_addr netstat -aon | grep $tx_xmlrpc_port
		ssh $uname@10.1.1.$my_addr netstat -aon | grep $rx_xmlrpc_port
		ssh $uname@10.1.1.$my_addr netstat -aon | grep $zmq_port
	fi

	if (( $fg_status == 1 ))
	then
		ssh $uname@10.1.1.$my_addr ps | grep python3
	fi

	if (( $kill_procs == 1 ))
	then
		echo "  Killing process ${pids[$i]}"
		ssh $uname@10.1.1.$my_addr kill -9 $my_pid
		sleep 1
	fi
	
	i=$((i + 1))
done

echo "  ------------"




