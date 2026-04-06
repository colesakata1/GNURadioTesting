#!/bin/bash

#################################################################### 
# get_info_pi.sh
#
# Initial Authors: Humza Ali / Myles Toole
#
# Description: This script shows Pi version, OS version, RAM memory 
# 		and disk space info of the given node.
#
# Input: bash get_info.sh -r 101,105
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
	echo "	### Bash script to get general information about Pi nodes ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-l = list of testbed node addresses (e.g., 'bash get_info_pi.sh -l 103,105,109')"
	echo "	-r = range of testbed node addresses (e.g., 'bash get_info_pi.sh -r 103,107')"
	echo "	-d [OPTIONAL] = List the microSD memory size for each specified node"
	echo "	-m [OPTIONAL] = List the RAM size for each specified node"
	echo "	-p [OPTIONAL] = List the WiFi Tx power for each specified node"
	echo "	-o [OPTIONAL] = List the installed OS for each specified node"
	echo "	-s [OPTIONAL] = List the VNC Status for each specified node" 
	echo "	-t [OPTIONAL] = List the current temperature reading for each specified node"
	echo "	-v [OPTIONAL] = List the Pi type or software version for each specified node"
	echo "                    (e.g., 'bash get_info_pi.sh -l 103 -v <software>' "
	echo "                                                    for <Pi,python3,iperf3,sudo> )"
	echo "                    (e.g., '-v Pi' for Pi type or '-v python3' for python3 version)"
	echo "	-w [OPTIONAL] = List the write speed for each specified node"
	echo "	-a [OPTIONAL] = List the available space for each specified node"
	echo "	-u [OPTIONAL] = client's username (e.g., '-u uname') (default: ucanlab)"
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

#-------------------------------------------------------------------

# Determine what software version is being requested
version_check()
{
	ver_check=1
	ver_option=$OPTARG
	#TODO: Add a warning/error for invalid options
	
}

#-------------------------------------------------------------------

# function to setup the top row of the output
setup_col_titles()
{
	#TODO: Find a way to auto-adjust the column widths
	
	temp1="   Node  "	
	temp2="  ------ "
	
	#------------------
	if (( $mem_check == 1 ))
	then
		temp1="$temp1   MEM  "
		temp2="$temp2 -------"
	fi

	#------------------
	if (( $ram_check == 1 ))
	then
		temp1="$temp1     RAM    "
		temp2="$temp2 -----------"
	fi
	
	#------------------
	if (( $power_check == 1 ))
	then
		temp1="$temp1   Tx Power "
		temp2="$temp2  ----------"
	fi
	
	#------------------
	if (( $os_check == 1 ))
	then
		temp1="$temp1      OS    "
		temp2="$temp2  ----------"
	fi
	
	#------------------
	if (( $vnc_check == 1 ))
	then
		temp1="$temp1  VNC Status"
		temp2="$temp2  ----------"
	fi
		
	#------------------
	if (( $temp_check == 1 ))
	then
		temp1="$temp1    Temp  "
		temp2="$temp2  --------"
	fi
		
	#------------------
	if (( $ver_check == 1 ))
	then
		temp1="$temp1   $ver_option Version "
		temp2="$temp2  ------------------"
	fi
	
	#------------------
	if (( $write_check == 1 ))
	then
		temp1="$temp1    Write Speed    "
		temp2="$temp2  ---------------"
	fi
	
	#------------------
	if (( $space_check == 1 ))
	then
		temp1="$temp1  Available Space"
		temp2="$temp2  ---------------"
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

ver_check=0
mem_check=0
ram_check=0
os_check=0	
vnc_check=0
temp_check=0	
power_check=0
write_check=0
space_check=0
uname=ucanlab # default
debug=0

#-------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hl:r:dmpostv:wau:' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;
		d)
			mem_check=1;;
		m)
			ram_check=1;;
		p)
			power_check=1;;
		o)
			os_check=1;;
		s) 
			vnc_check=1;;			
		t)
			temp_check=1;;	
		w) 
			write_check=1;;	
		a) 
			space_check=1;; 	
		v)
			version_check;;
		u)
			uname=$OPTARG;;	
	esac
done


#############################
#####     Main Code     #####
#############################
#-------------------------------------------------------------------

# Call function to setup top row of output
setup_col_titles

# Loop through addresses and get the desired info
for i in "${addresses[@]}"
do

	# Put Pi number in first column
	temp="    $i"
	
	#------------------
	# check for microSD memory sie
	if (( $mem_check == 1 ))
	then
		my_mem=$(ssh $uname@"10.1.1.$i" df -H | grep "root" | awk '{print $2}')
		
		# Adding this as a temp fix since the rootfs partition doesn't seem to show in (newer?) Pi OS versions
		# (This fix is confirmed for Pi 3B+) 
		if [ -z "$my_mem" ] # Check for empty string
		then
			my_mem=$(ssh $uname@"10.1.1.$i" df -H | grep "/dev/mmcblk0p2" | awk '{print $2}')
		fi
		temp="$temp     $my_mem"
	fi


	#------------------
	# check for ram
	if (( $ram_check == 1 ))
	then
		temp="$temp   $(ssh $uname@"10.1.1.$i" cat /proc/meminfo | grep "MemTotal" | awk '{print $2 " " $3}')"
	fi
	
	#------------------
	# check for Tx Power
	if (( $power_check == 1 ))
	then
		#NOTE: Requires sudo to access iwconfig
		my_power=$(ssh $uname@"10.1.1.$i" sudo iwconfig wlan0 | grep "Tx-Power" | awk -F[\=] '{print $3}')
		if [ -z "$my_power" ] # Check for empty string
		then
			my_power="WiFi Off "
		fi
		
		temp="$temp     $my_power"
	fi
		
	#------------------
	# check for os
	if (( $os_check == 1 ))
	then
		temp="$temp    $(ssh $uname@"10.1.1.$i" cat /etc/os-release | grep "^ID=" | awk -F'[/=]' '{print $2}')"
		temp="$temp $(ssh $uname@"10.1.1.$i" getconf LONG_BIT)"
	fi
	
	#------------------
	# check for vnc status 
	if (( $vnc_check == 1 ))
	then
		temp="$temp    $(ssh $uname@"10.1.1.$i" netstat -tuln | grep 5900 | awk '{print $6}')"
	fi
	
	#------------------
	# check for current temperature
	if (( $temp_check == 1 ))
	then
		temp="$temp    $(ssh $uname@"10.1.1.$i" vcgencmd measure_temp | awk -F'[/=]' '{print $2}')"
	fi

	#------------------
	# check for write speed 
	if (( $write_check == 1 )) 
	then 
		TEST="test_file.tmp"
		write_speed=$(ssh $uname@"10.1.1.$i" dd if=/dev/zero of=$TEST bs=100M count=1 conv=fdatasync 2>&1 | grep --color=never -o '[0-9.]* MB/s' && rm -f test_file.tmp)
		temp="$temp       $write_speed"
	fi

	#------------------
	# check for available space 
	if (( $space_check == 1 )) 
	then 
		temp="$temp         $(ssh $uname@"10.1.1.$i" df -h | grep "/dev/mmcblk0p2" | awk '{print $3}')"
	fi
	
	#------------------
	# check for version
	if (( $ver_check == 1 ))
	then
		if [ $ver_option = "Pi" ] #NOTE: Use 'if [ ]' for string comparison
		then
			temp="$temp  $(ssh $uname@"10.1.1.$i" cat /proc/cpuinfo | grep "Model" | awk '{$1=$2=""; print $0}')"
		fi

		if [ $ver_option = "python3" ] #NOTE: Use 'if [ ]' for string comparison
		then
			temp="$temp    $(ssh $uname@"10.1.1.$i" python3 -V)"
		fi

		if [ $ver_option = "iperf3" ] #NOTE: Use 'if [ ]' for string comparison
		then
			temp="$temp    $(ssh $uname@"10.1.1.$i" iperf3 -v | grep "iperf" | awk '{print $2" "$3" "$4}')"
		fi
		
		if [ $ver_option = "sudo" ] #NOTE: Use 'if [ ]' for string comparison
		then
			temp="$temp    $(ssh $uname@"10.1.1.$i" sudo -V | grep "Sudo version" | awk '{print $3}')"
		fi
	fi
	
	# Print information for each Pi on a single Row
	echo $temp	
	
done

echo ""
