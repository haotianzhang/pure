#!/bin/bash

LINUX_DISTRO=$1
KERNEL_META_PATH=$2
BSP_NAME=$3

echo -e "\\n\t*****************************************"
echo -e "\tCurrent LINUX DISTRO: $LINUX_DISTRO"
echo -e "\tKMETA PATH: $KERNEL_META_PATH"
echo -e "\tBSP NAME: $BSP_NAME"
echo -e "\t*****************************************\\n"

TEST_ENABLED=`grep _kconf $KERNEL_META_PATH/$BSP_NAME-*-meta | awk '$3 ~ /non/ {print $4}' | sed "s/[^/]*[/]//g" | sed "s/.cfg.*//g"`
for i in $TEST_ENABLED; do
	[ -d testcases/$i ] && { 
		cp `grep _kconf $KERNEL_META_PATH/$BSP_NAME-*-meta | grep $i | awk '$3 ~ /non/ {print $4}'` testcases/$i/; 
		echo "++++TEST" $i "enabled" 
		TEST_MATRIX+="$i "
		sed -i s/TEST=.*/TEST=enabled/g testcases/$i/$i.inc
	} || { 
		echo "----TEST" $i "NO cases"
		#sed -i s/TEST=.*/TEST=disabled/g testcases/$i/$i.inc
	}
done
echo $TEST_ENABLED
touch test_cases.matrix
echo $TEST_MATRIX > test_cases.matrix
echo $1 >> test_cases.matrix

