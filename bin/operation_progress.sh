#!/bin/bash
TIMEOUT=$2
QUIET_FLAG=$4
b="/"
for((i=0; i<$TIMEOUT; i++))
do
	#pstree | grep -q runtest.sh || exit
	if [ X"$QUIET_FLAG" != X"1" ];then
		printf "\tplease wait %s \r" $b
		sleep 0.1
		let "c=$i % 4"
		case $c in
        		0) b="/";;
	        	1) b="-";;
	        	2) b="\\";;
	        	3) b="|";;
		esac
	else
		sleep 0.1
	fi	
	[ -d /proc/$1 ] || exit
	#pstree | grep -q main_test.sh || exit
done    
echo    

pstree | grep -q runtest.sh && {
	killall runtest.sh 
	[ -e $3.kill ] && rm $3.kill
	touch $3.kill
	echo $3 "TIME OUT: Killed by the watch dog" > $3.kill
}

