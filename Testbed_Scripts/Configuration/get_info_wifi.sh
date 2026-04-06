#!/bin/bash

#################################################################### 
# get_info_wifi.sh
#
# Initial Authors: Humza Ali / Myles Toole
#
# Description: This script is meant to check the status of all the nodes 
#    in our system (whether or not they are connected to the test network)
#
# Input:
#
####################################################################

#############################
#####     Functions     #####
#############################
#-------------------------------------------------------------------
help()
{
	echo ""
	echo "	### Bash script to list SSIDs of WLAN connections for testbed nodes ###"
	echo "	----------------------------------------------------------------------------"
	echo "	-l = list of testbed node addresses (e.g., get_info_wifi.sh -l 103,105,109)"
	echo "	-r = range of testbed node addresses (e.g., get_info_wifi.sh -r 103,107)"
	echo "	-c [OPTIONAL] = List the connected channel on wlan0 for each specified node"
	echo "	-p [OPTIONAL] = List the RSSI for each specified node"
	echo "	-s [OPTIONAL] = List the SSID for each specified node"
	echo "	-u [OPTIONAL] = client's username (e.g., '-u uname') (default: ucanlab)"
	echo ""
	exit
}

#-------------------------------------------------------------------
# Parse input and create addresses array from arg1 through arg2
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
	
	#------------------
	if (( $channel_check == 1 ))
	then
		temp1="$temp1   Channel  "
		temp2="$temp2 -----------"
	fi
	
	#------------------
	if (( $rssi_check == 1 ))
	then
		temp1="$temp1     RSSI   "
		temp2="$temp2  ----------"
	fi
		
	#------------------
	if (( $ssid_check == 1 ))
	then
		temp1="$temp1      SSID    "
		temp2="$temp2  ------------"
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
uname=ucanlab   # default
debug=0
channel_check=0
rssi_check=0
ssid_check=0


#-------------------------------------------------------------------
# Get arguments and set appropriate parameters
while getopts 'hl:r:cpsu:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			IFS=','
			read -ra addresses <<< "$OPTARG"
			;;
		r)
			addresses_range;;			
		c)
			channel_check=1;;
		p)
			rssi_check=1;;
		s)
			ssid_check=1;;
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
	echo "  ##### Debug Info: #####"
	echo "  Nodes: ${addresses[@]}"
	echo "  Check Channel: $channel_check" 
	echo "  Check RSSI: $rssi_check" 
	echo "  Check SSID: $ssid_check" 
	echo "  UName: $uname"
	echo ""
	exit
fi

# Call function to setup top row of output
setup_col_titles

# Loop through addresses and get the SSID for each node
for i in "${addresses[@]}"
do

	# Put Pi number in first column
	temp="    $i"
	
	my_ssid=$(ssh $uname@"10.1.1.$i" /usr/sbin/iwgetid -r)
	
	if [ -z "$my_ssid" ]
	then
		temp="$temp    *** WiFi Not Connected *** "
	else

		#------------------
		# check for channel
		if (( $channel_check == 1 ))
		then
			sv="Frequency:" # search value for awk
			chan=$(ssh $uname@"10.1.1.$i" sudo iwconfig wlan0 | grep $sv | awk -F $sv '{print $2}' | awk '{print $1 " " $2}')
			temp="$temp    $chan"
		fi
	
		#------------------
		# check for rssi
		if (( $rssi_check == 1 ))
		then
			sv="Signal level=" # search value for awk
			rssi=$(ssh $uname@"10.1.1.$i" sudo iwconfig wlan0 | grep $sv | awk -F $sv '{print $2}' | awk '{print $1 " " $2}')
			temp="$temp    $rssi"
		fi

		#------------------
		# check for ssid
		if (( $ssid_check == 1 ))
		then
			# NOTE: we already got the SSID above to check connection
			temp="$temp    $my_ssid"
		fi
	fi	
	
#	echo "pi $i SSID:"
#	ssh $uname@"10.1.1.$i" /usr/sbin/iwgetid -r

	# Print information for each Pi on a single Row
	echo $temp
done

echo "" # Extra line for readability in output




