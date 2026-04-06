#!/bin/bash

##############################################################################################
# sdr_tx_update.sh
#
# Author: MR
#
# Description: This script updates the sdr transmission characteristics on set of nodes
#
# Input: 
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
	echo "	### Bash script to initiate tone transmissions at specified nodes ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-l = list of client node addresses (e.g., 'bash sdr_tx_update.sh -l 103,105,109')"
	echo "	-r = range of client node addresses (e.g., 'bash sdr_tx_update.sh -r 103,107')"
	echo "	-c = list of carrier frequencies for corresponding nodes "
	echo "	          (e.g., 'bash sdr_tx_update.sh -l 101,103 -c 915e6,2.4e9')"
	echo "	-f [OPTIONAL] = list of tone frequencies for corresponding nodes "
	echo "	          (e.g., 'bash sdr_tx_update.sh -l 101,103 -f 1e5,2e5')"
	echo "	-m [OPTIONAL] = list of scaling factors for OFDM transmission"
	echo "	          (e.g., 'bash sdr_tx_update.sh -l 101,103 -m 0.1,0.05')"
	echo "	-g [OPTIONAL] = list of gain values for corresponding nodes "
	echo "	          (e.g., 'bash sdr_tx_update.sh -l 101,103 -g 25,40')"
	echo "	-s [OPTIONAL] = list of signal types for corresponding nodes "
	echo "	          (e.g., 'bash sdr_tx_update.sh -l 101,103 -s 0,2')"
	echo "	             (0: disable, 1: tone, 2: OFDM)"
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

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
carrier_freq_list()
{
	set_carrier_freqs=1
	IFS=','
	read -ra my_carrier_freqs <<< "$OPTARG"
}

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
sig_freq_list()
{
	set_sig_freqs=1
	IFS=','
	read -ra my_sig_freqs <<< "$OPTARG"
}

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
scaling_list()
{
	set_ofdm_scale_vals=1
	IFS=','
	read -ra my_scale_vals <<< "$OPTARG"
}

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
gain_list()
{
	set_gain_vals=1
	IFS=','
	read -ra my_gain_vals <<< "$OPTARG"
}

#---------------------------------------------------------------------------------------------
# Creates array from command line inputs
sig_select_list()
{
	set_sig_vals=1
	IFS=','
	read -ra my_sig_vals <<< "$OPTARG"
}


#############################
#####   Setup Params    #####
#############################
#---------------------------------------------------------------------------------------------
# Set default parameters

uname=ucanlab # default
debug=0
set_carrier_freqs=0
set_sig_freqs=0
set_ofdm_scale_vals=0
set_gain_vals=0
set_sig_vals=0

#---------------------------------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hl:r:c:f:m:g:s:u:d' OPTION; do
	case "$OPTION" in
		h)
			help;;
		l)
			addresses_list;;
		r)
			addresses_range;;
		c)
			carrier_freq_list;;
		f)
			sig_freq_list;;
		m)
			scaling_list;;
		g)
			gain_list;;
		s)
			sig_select_list;;
		u)
			uname=$OPTARG;; # in case the username is not the default one, use this flag to user another username
		d)
			debug=1;;
	esac
done

# Setup Pi's top directory after input, in case Pi username is not default
top_dir=/home/$uname/ucan_TB


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
	echo "  Carrier Frequencies: ${my_carrier_freqs[@]}"
	echo "  Signal Frequencies: ${my_sig_freqs[@]}"
	echo "  Scaling Values: ${my_scale_vals[@]}"
	echo "  Gain Values: ${my_gain_vals[@]}"
	echo "  Signal Select Values: ${my_sig_vals[@]}"
	echo "  Testbed Folder: $top_dir"
	echo "  UName: $uname"
	echo ""
	exit
fi	

i=0
while [[ $i -lt ${#my_addresses[@]} ]]; do # loop through number of nodes
	# get desired values from list 
	my_addr=${my_addresses[$i]}
		
	temp="Updating Pi $my_addr"
		
	#------------------
	# check if updating signal types
	if (( $set_sig_vals == 1 ))
	then	
		my_sig=${my_sig_vals[$i]}
		temp="$temp to signal $my_sig ... "
		python3 SDR_control/set_remote_params.py -n $my_addr -s $my_sig 
	fi

	#------------------
	# check if updating carrier frequencies
	if (( $set_carrier_freqs == 1 ))
	then	
		my_carrier=${my_carrier_freqs[$i]}
		temp="$temp carrier: $my_carrier ... "
		python3 SDR_control/set_remote_params.py -n $my_addr -c $my_carrier 
	fi

	#------------------
	# check if updating frequencies
	if (( $set_sig_freqs == 1 ))
	then	
		my_f=${my_sig_freqs[$i]}
		temp="$temp frequency: $my_f,"
		python3 SDR_control/set_remote_params.py -n $my_addr -f $my_f 
	fi
	
	#------------------
	# check if updating ofdm scaling values
	if (( $set_ofdm_scale_vals == 1 ))
	then	
		my_m=${my_scale_vals[$i]}
		temp="$temp scaling: $my_m,"
		python3 SDR_control/set_remote_params.py -n $my_addr -m $my_m 
	fi
	
	#------------------
	# check if updating gains
	if (( $set_gain_vals == 1 ))
	then	
		my_g=${my_gain_vals[$i]}
		temp="$temp gain: $my_g,"
		python3 SDR_control/set_remote_params.py -n $my_addr -g $my_g 
	fi
	
	echo $temp
	
	i=$((i + 1))
done


