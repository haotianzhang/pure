#!/bin/bash

source /opt/pure/lib/function.sh

TC_PATH=`dirname $0`
TC_SCRIPT=`basename $0`
ERROR=0
PRIORITY=20
declare -i TOTAL=0
declare -i FAIL=0
declare -i PASS=0


# If users run pi tests from sshd, they need to improve the priority
# sshd using the following command. 

# chrt -p -f $PRIORITY $PPID

# If users run pi test from console, they need to add the prioirity 
# of the shell using the following command.

# chrt -p -f $PRIORITY $$


function do_test
{
	echo ""
	echo "Run pi-futex sub tests $1:"
	echo "=============================="
	echo ""
        TOTAL=$TOTAL+1
	$TC_PATH/threads/pi_test/pitest-$1
}

checkreturn()
{
    if [ $1 -eq 0 ]; then
        echo 
        echo "******Pi-futex sub test $2 pass******"
        PASS=$PASS+1
    else
        echo
        echo "******Pi-futex sub test $2 fail******"
	FAIL=$FAIL+1	
        ERROR=1;
    fi
    echo "*******Pi-futex sub test $2 end*******"
}


#Main entry

killall -9 watchdogtimer.sh
#chrt -f $PRIORITY threads/tools/watchdogtimer.sh &

echo "#####################################"
echo " Start to test priority inversion    "
echo "#####################################"

if test X"$1" != "X"; then
        do_test $1
        checkreturn $? $1

else
	fno=1
        while((fno<=6));do
		do_test $fno
                checkreturn $? $fno
                fno=$(($fno + 1))
        done
fi

echo -ne "\t\t*****************\n"
echo -ne "\t\t*   TOTAL:   "  $TOTAL *"\n"
echo -ne "\t\t*   PASSED:  "  $PASS *"\n"
echo -ne "\t\t*   FAILED:  "  $FAIL *"\n"
echo -ne "\t\t*****************\n"

killall -9 watchdogtimer.sh
killall sleep

[ $ERROR -eq 1 ] && exit $TEST_RETVAL_FAIL;

