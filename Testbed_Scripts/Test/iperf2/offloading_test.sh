#!/bin/bash
r2=112
off=6
counter=0
while [ $off -ge 0 ]
do
	echo $counter
	echo $off
	noff="$((r2-counter))"
	bash base_test.sh -t 20 -d 120 -r "101 $noff" -s "1.200 1.200 1.200 1.200 1.200 1.200 2.200 2.200 2.200 2.200 2.200 2.200"
	echo $noff
	((counter++))
	((off=off-1))
done
