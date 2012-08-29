#!/bin/bash

source /opt/pure/lib/function.sh

rm -rf /Fruits
rm -rf /Vegetables
mkdir /Fruits
mkdir /Vegetables

touch /Fruits/Apple
touch /Fruits/Tomato
touch /Vegetables/Carrots
touch /Vegetables/Tomato 

echo "I am botanically a fruit" > /Fruits/Tomato
echo "I am horticulturally a veggie" >  /Vegetables/Tomato 

if [ ! -d /mnt/healthy ]; then
   mkdir /mnt/healthy
fi

mount -t unionfs -o dirs=/Fruits:/Vegetables none /mnt/healthy 
x=`ls /mnt/healthy/ | wc -l`;
if [ "$x" != "3" ]; then
   echo "error. incorrect number of entries in the filesystem";
   exit $TEST_RETVAL_FAIL;
fi;

x=`cat /mnt/healthy/Tomato`;
if [ "$x" != "I am botanically a fruit" ]; then
   echo "error. incorrect context from /mnt/health/Tomato";
   exit $TEST_RETVAL_FAIL;
fi;

umount /mnt/healthy
mount -t unionfs -o dirs=/Vegetables:/Fruits none /mnt/healthy
x=`cat /mnt/healthy/Tomato`;
if [ "$x" != "I am horticulturally a veggie" ]; then
   echo "error. incorrect context from /mnt/health/Tomato";
   exit $TEST_RETVAL_FAIL;
fi;

umount /mnt/healthy


