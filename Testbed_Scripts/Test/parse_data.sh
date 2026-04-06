#!/bin/bash

#####################################################################################
# parse_data.sh
#
# Author: MR
#
# Description: Search through Pi directories in a specified folder. Pull out the 
# 		desired value from each results file and aggregate in a single file
#
# Input: bash parse_data.sh -d <read directory> -f <results_file>
#
#####################################################################################

#############################
#####     Functions     #####
#############################
#------------------------------------------------------------------------------------

help()
{
	echo ""
	echo "	### Bash script to parse results on TC and store to a desired folder ###"
	echo "	---------------------------------------------------------------------------------------"
	echo "	-d = directory with results (location given to transfer.sh when moving to TC)"
	echo "	-f = file name to store aggregated results"
	echo "	-s [OPTIONAL] = flag to use sender throughput rather than default receiver throughput "
	echo ""
	exit
}



#############################
#####   Setup Params    #####
#############################
#---------------------------------------------------------------------------------------------
# Set default parameters

debug=0
sender=0

#------------------------------------------------------------------------------------
# Get arguments and set appropriate parameters

while getopts 'hd:f:s' OPTION; do
	case "$OPTION" in
		h)
			help;;
		d)
			dir_name=$OPTARG;;
		f)
			file_name=$OPTARG;;
		s)
			sender=1;;			
	esac
done

# OK to use relative home, ~, for TC location
top_dir_TC=~/ucan_TB/TB_Results


#############################
#####     Main Code     #####
#############################
#------------------------------------------------------------------------------------
echo $folder_name
if [ ! -d $top_dir_TC/$dir_name ] 
then
	echo "Directory does not exist on the TC"	
elif [ -a $file_name ]
then
	echo "File already exists on the TC"
else
	# Create the new file
	touch $file_name

	# Find all the Pi directories
	# NOTE: The extra () make sure results are stored as an array, not a single value
	my_dirs=($(ls -d $top_dir_TC/$dir_name/${dir_name}*/))
	#echo "Size: ${#my_dirs[@]}"
	
	i=0
	while [[ $i -lt ${#my_dirs[@]} ]]; 
	do # loop through Pi directories	
		#echo ${my_dirs[$i]}
		# Find all the results files in the current directory
		# NOTE: The extra () make sure results are stored as an array, not a single value
		my_files=($(ls ${my_dirs[$i]}))
		#echo "Size: ${#my_files[@]}"		

		j=0
		
		# Start each line with the pi number (pulled from the directory name)
		temp=$(echo ${my_dirs[$i]} | awk -F "${dir_name}_pi" '{print $2}')
		
		while [[ $j -lt ${#my_files[@]} ]]; 
		do # loop through results files	
			#echo "  ${my_files[$j]}"
			
			# Parse the file and get the throughput
			if (( $sender == 1 ))
			then
				temp="$temp, $(cat ${my_dirs[$i]}/${my_files[$j]} | grep 'sender' | awk '{print $7 ", " $8}')"
			else
				temp="$temp, $(cat ${my_dirs[$i]}/${my_files[$j]} | grep 'receiver' | awk '{print $7 ", " $8}')"
			fi
			
			j=$((j + 1))
		done
		
		echo $temp >> $file_name
		
		i=$((i + 1))
	done
fi
