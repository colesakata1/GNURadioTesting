#!/bin/bash

#################################################################### 
# set_wlan_local.sh
#
# Author: MR
#
# Description: This script runs locally on the Pi to modify WLAN
#
# Input:
#
####################################################################

#############################
#####   Setup Params    #####
#############################
my_version=1.0.0 #Keep version for all Pi scripts to avoid conflicts

#-------------------------------------------------------------------
# Get arguments and set appropriate parameters
while getopts 's:p:v' OPTION; do
	case "$OPTION" in
		s)
			SSID=$OPTARG;;			
		p)
			pw=$OPTARG;;
		v)
			echo "Version: $my_version"
			exit;;
	esac
done



#############################
#####     Main Code     #####
#############################
#-------------------------------------------------------------------

# Removes the network{ ... } info from wpa_supplicant
sudo sed -i '/network=/{:a;N;/}/!ba};/ssid/d' /etc/wpa_supplicant/wpa_supplicant.conf 

# Generates new network infor with wpa_passphrase, then adds to wpa_supplicant
wpa_passphrase $SSID $pw | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null




