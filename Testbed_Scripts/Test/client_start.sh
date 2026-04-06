#!/bin/bash

##############################################################################################
# client_start.sh
#
# Author: Victoria Planchart
#
# Description: This script starts a number of clients and save the iperf results in a folder 
#		in the RPis. It will check if the given folder already exists in the RPis; 
#		if they don't exist, it will create the folder and store the iperf results. 
#		If the folder exists, it will display an error message indicating on how many 
#		RPis the folder exists in, and the iperf test will not run. 
#		It takes the IP address suffix of the RPis, the IP address suffix of the 
#		server, the duration of the test in seconds, the number of trials to be run 
#		and the name of the folder where the results will be saved in the RPpi. 
#
# Input: bash client_start.sh -n 3 -i 201 -t 5 -l 5 -f <folder name> -s "server address" or
#	 bash client_start.sh -a "103 106 108 112" -i 201 -t 5 -l 5 -f <folder name> -s "server address"
#
# **For Help, enter -h**
#
##############################################################################################

#############################
#####     Functions     #####
#############################
#---------------------------------------------------------------------------------------------

help()
{
	echo ""
	echo "	### Bash script initiate iperf clients for multi-node network testing ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-l = list of client node addresses (e.g., 'bash client_start.sh -l 103,105,109')"
	echo "	-r = range of client node addresses (e.g., 'bash client_start.sh -r 103,107')"
	echo "	-s = input server's network address. 1 for 192.168.1.X or 2 for 192.168.2.X, etc."
	echo "	        (e.g., '-s 1,1,2,1' or '-s 1' if all clients connecting to same server)"	
	echo "	-a [OPTIONAL] = the server's IP device address. (-a 201 for IP: 192.168.1.201) (default: 201)"
	echo "	-f = input the name of the folder where the results will be saved in the RPis"
	echo "	-u [OPTIONAL] = input client's username if the deffault one (ucanlab) is not used"
	echo ""
	echo "	# iperf settings #"
	echo "	-t [OPTIONAL] = input test duration. (-t 15 will run tests for 15 seconds) (default: 5)"
	echo "	-k [OPTIONAL] = input number of iterations for the test to run (default: 2)"
	echo "	-i [OPTIONAL] = input iperf reporting interval in seconds (default: 1)"
	echo ""
	exit
}

#-------------------------------------------------------------------
# loop creates values for temp_number by subtracting 100 from the entered IP (103 106 112 will create values 3 6 12)
# creates values for my_ports by adding 5200 and the temp_number. my_s values will equal temp_number values.
define_ports()
{
	i=0
	while [[ $i -lt ${#my_addresses[@]} ]]; do
		temp_number=$((${my_addresses[$i]}-100))
		my_ports[$i]=$((5200+$temp_number))
		my_s[$i]=$temp_number	
		i=$((i + 1))
	done
}

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
addresses_list()
{
	IFS=','
	read -ra my_addresses <<< "$OPTARG"
	define_ports #Function to get arrays for ports and s values
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
	define_ports #Function to get arrays for ports and s values
}


#---------------------------------------------------------------------------------------------
# reads "setup_server_array", remove the blank spaces and creates a new "temp_server_array" array.
#   NOTE: Assumes my_addresses have already been setup with -r or -l (don't change order in getopts)
server_array_setup()
{
	IFS=','
	read -ra temp_server_array <<< "$OPTARG"
	
	# if statement checks if the array length equals to 1 (single server address for all clients)
	if [ ${#temp_server_array[@]} -eq 1 ]; then
		i=0
		# if the array length is 1, it assigns the only value to the array of lentgh $my_address
		while [ $i -lt ${#my_addresses[@]} ]; do 
			my_server_array[$i]=$temp_server_array
			i=$((i + 1))
		done
	else
		# if the array length is more than 1, it creates the array with more than one value.
		my_server_array=("${temp_server_array[@]}")
	fi	
}


#############################
#####   Setup Params    #####
#############################
#---------------------------------------------------------------------------------------------
# Set default parameters

uname=ucanlab # default
ip=201
time=5
trials=2
interval=1
debug=0

#---------------------------------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hl:r:s:a:f:u:t:k:i:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;
		s)
			server_array_setup;;
		a)
			ip=$OPTARG;; # takes ip suffix, e.g 201
		f)
			folder_name=$OPTARG;;
		u)
			uname=$OPTARG;; # in case the username is not the default one, use this flag to user another username
		t)
			time=$OPTARG;; # takes test durantion in seconds
		k)
			trials=$OPTARG;; # takes number of trials
		i)
			interval=$OPTARG;; #iperf reporting interval
		d)
			debug=1;;
	esac
done

# Setup Pi's top directory after input, in case Pi username is not default
top_dir=/home/$uname/ucan_TB/TB_Results


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
	echo "  Server networks: ${my_server_array[@]}"
	echo "  Server device address: $ip"
	echo "  Ports: ${my_ports[@]}"
	echo "  Processes: ${my_s[@]}"
	echo "  Results Folder: $top_dir/${folder_name}_piXXX"
	echo "  iperf time: $time"
	echo "  iperf trials: $trials"
	echo "  iperf interval: $interval"
	echo "  UName: $uname"
	echo ""
	exit
fi	

i=0
error=0
while [[ $i -lt ${#my_addresses[@]} ]]; do # loop through specified clients
	# checks if the given directory folder exists in the client nodes
	if ssh $uname@10.1.1.${my_addresses[$i]} [ -d $top_dir/${folder_name}_pi${my_addresses[$i]} ] 
	then
		# if it exists, the error count goes up by one
		error=$((error + 1))
		echo "Directory exists in pi ${my_addresses[$i]}"
	else
		# if it does not exist, it creates the given directory
		ssh $uname@10.1.1.${my_addresses[$i]} mkdir -p $top_dir/${folder_name}_pi${my_addresses[$i]} 
		echo "Directory created in pi ${my_addresses[$i]}"
	fi
	i=$((i + 1))
done


# if statement will check if the error count is zero
if [ $error -lt 1 ] # if it's zero, the test in the while loop will run
then
	x=0
	while [[ $x -lt $trials ]] # loop through number of trials
	do
		x=$(($x+1))
		echo "Starting Test $x of $trials"
		
		i=0
		while [[ $i -lt ${#my_addresses[@]} ]]; do # loop through number of clients
			# ssh in the client nodes, start the clients and run the test
			ssh $uname@10.1.1.${my_addresses[$i]}  "iperf3 -c 192.168.${my_server_array[$i]}.$ip -t $time s${my_s[$i]} -p ${my_ports[$i]} -i $interval > $top_dir/${folder_name}_pi${my_addresses[$i]}/Results_$x.txt" &	
			i=$((i + 1))
		done
		
		# Delay for approximate time of tests (since we get here at the START of the tests)
		sleep $time
		
		# Delay after each test
		sleep 5	
		echo "-- Completed Test $x of $trials"
		sleep 5

	done
	
	echo "-----------------"
	echo "Test is completed"
	
# if the error count is greater than zero, the iperf test will not be executed.
else
	echo "Directory exists in $error pis"
fi

