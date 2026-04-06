#!/bin/bash



if [[ -z "$@" ]] 
then

echo "Please enter the number of trials, duration (in seconds), range minimum and range maximum seperated by a space for this test."
echo "Input the corresponding ip addresses for the servers that each pi will connect to. Follow the syntax below."
echo "Syntax: trials duration range1 range2--> 1 2 "101 104" "1.200 2.200 1.200 2.200""
read -a input
echo ${input[@]}
run_tests ${input[0]} ${input[1]} "$(echo ${input[2]})" "$(echo ${input[3]})"

else
trial=0
dur=0
r1=0
r2=0
while getopts ":d:t:s:i:r:" options; do
	case "${options}" in 
		d ) dur=${OPTARG}
			echo $dur
			;;
                s ) set -f
                    IFS=' '
            	    ip=($OPTARG)
		    echo ${ip[@]}
		    ;;	

		t ) trial=${OPTARG}
			echo $trial
			;;
		
		r ) set -f
            	    IFS=' '
            	    array=($OPTARG)
            	    r1=${array[0]} 
            	    r2=${array[1]}
		    echo ${array[@]}
            	    declare -a narr
            	    for (( i=$r1; i<=$r2; i++ ))
            	    do
            	    	narr+=($i)
            	    done
            	    echo $r1
            	    echo $r2
            
           	    ;;
       	        i ) set -f
                    IFS=' '
            	    narr=($OPTARG)
            	    echo ${narr[@]}
		    echo ${narr[0]}
		    echo ${narr[1]}
            	    ;;
	esac
done

for i in ${narr[@]}; do
echo $i
done
#test "$(echo ${ip[@]})" "$(echo ${narr[@]})"
#run_tests $trial $dur "$(echo ${narr[@]})" "$(echo ${ip[@]})"
ip_server="192.168"
base_port=5000
ip_prefix="10.1.1"

echo "${#narr[@]}"

# Type of iperf
type="-c"

# Iperf test for loop with number of tets and types
#ssh pi@$ip_server screen -d -m iperf -s

until [[ $counter -ge $trial ]]
do
	((counter++))
	echo "This is trial " $counter
	for (( i=0; i<=(${#narr[@]}-1); i++ )); do
		echo "Current Static IP address"
		echo ${narr[$i]}
		echo "Server IP"
		echo ${ip[$i]}
		ssh pi@"$ip_prefix.${narr[$i]}" iperf $type $ip_server.${ip[$i]} -t $dur | awk 'END{print $7","}'>> $ip_prefix.${narr[$i]}.csv &
	done
	sleep $dur
done
echo "Test is finished"
fi
shift $((OPTIND -1))
