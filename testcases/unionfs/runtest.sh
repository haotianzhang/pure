#!/bin/bash

source /opt/pure/lib/function.sh

FRUITS_DIR="/Fruits"
VEGETABLES_DIR="/Vegetables"


do_exit()
{
    echo $1
    echo 
    exit $TEST_RETVAL_FAIL
}
echo "###########################################"
echo " Start to test unionfs"
echo "###########################################"
echo


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


umount /mnt


[ ! -d /mnt/healthy ] && mkdir /mnt/healthy

mount -t unionfs -o dirs=/Fruits:/Vegetables none /mnt/healthy
[ $? -ne 0 ] && do_exit "Failed to test unionfs"

x=`ls /mnt/healthy/ | wc -l`;
[ "$x" != "3" ] && do_exit "error. incorrect number of entries in the filesystem"
x=`cat /mnt/healthy/Tomato`;
[ "$x" != "I am botanically a fruit" ] && do_exit "error. incorrect context from /mnt/health/Tomato"
umount /mnt/healthy

mount -t unionfs -o dirs=/Vegetables:/Fruits none /mnt/healthy
[ $? -ne 0 ] && do_exit "Failed to test unionfs"

x=`ls /mnt/healthy/ | wc -l`;
[ "$x" != "3" ] && do_exit "error. incorrect number of entries in the filesystem"
x=`cat /mnt/healthy/Tomato`;
[ "$x" != "I am horticulturally a veggie" ] && do_exit "error. incorrect context from /mnt/health/Tomato"
umount /mnt/healthy

./unionfs.sh

if [ $? = 0 ]; then

echo "###########################################"
echo " PASS to test unionfs"
echo "###########################################"
echo
exit $TEST_RETVAL_PASS

else 

echo "###########################################"
echo " FAIL to test unionfs"
echo "###########################################"
echo


exit $TEST_RETVAL_FAIL

fi
